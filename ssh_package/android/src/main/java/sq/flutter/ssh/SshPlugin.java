package sq.flutter.ssh;

import android.util.Log;
import android.os.Handler;
import android.os.Looper;

import com.jcraft.jsch.Channel;
import com.jcraft.jsch.ChannelExec;
import com.jcraft.jsch.ChannelSftp;
import com.jcraft.jsch.ChannelSftp.LsEntry;
import com.jcraft.jsch.ChannelShell;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.JSchException;
import com.jcraft.jsch.Session;
import com.jcraft.jsch.SftpException;
import com.jcraft.jsch.SftpProgressMonitor;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Vector;
import java.text.SimpleDateFormat;
import java.util.Date;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** SshPlugin */
public class SshPlugin implements MethodCallHandler, StreamHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "ssh");
    final EventChannel eventChannel = new EventChannel(registrar.messenger(), "shell_sftp");
    final SshPlugin instance = new SshPlugin();
    channel.setMethodCallHandler(instance);
    eventChannel.setStreamHandler(instance);
  }

  // MethodChannel.Result wrapper that responds on the platform thread.
  private static class MethodResultWrapper implements Result {
    private Result methodResult;
    private Handler handler;

    MethodResultWrapper(Result result) {
      methodResult = result;
      handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(final Object result) {
      handler.post(
          new Runnable() {
            @Override
            public void run() {
              methodResult.success(result);
            }
          });
    }

    @Override
    public void error(
        final String errorCode, final String errorMessage, final Object errorDetails) {
      handler.post(
          new Runnable() {
            @Override
            public void run() {
              methodResult.error(errorCode, errorMessage, errorDetails);
            }
          });
    }

    @Override
    public void notImplemented() {
      handler.post(
          new Runnable() {
            @Override
            public void run() {
              methodResult.notImplemented();
            }
          });
    }
  }

  private static class MainThreadEventSink implements EventChannel.EventSink {
    private EventChannel.EventSink eventSink;
    private Handler handler;

    MainThreadEventSink(EventChannel.EventSink eventSink) {
      this.eventSink = eventSink;
      handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(final Object o) {
      handler.post(new Runnable() {
        @Override
        public void run() {
          eventSink.success(o);
        }
      });
    }

    @Override
    public void error(final String s, final String s1, final Object o) {
      handler.post(new Runnable() {
        @Override
        public void run() {
          eventSink.error(s, s1, o);
        }
      });
    }

    @Override
    public void endOfStream() {
      handler.post(new Runnable() {
        @Override
        public void run() {
          eventSink.endOfStream();
        }
      });
    }
  }

  @Override
  public void onMethodCall(MethodCall call, Result rawResult) {
    Result result = new MethodResultWrapper(rawResult);
    if (call.method.equals("connectToHost")) {
      connectToHost((HashMap) call.arguments, result);
    } else if (call.method.equals("execute")) {
      execute((HashMap) call.arguments, result);
    } else if (call.method.equals("portForwardL")) {
      portForwardL((HashMap) call.arguments, result);
    } else if (call.method.equals("startShell")) {
      startShell((HashMap) call.arguments, result);
    } else if (call.method.equals("writeToShell")) {
      writeToShell((HashMap) call.arguments, result);
    } else if (call.method.equals("closeShell")) {
      closeShell((HashMap) call.arguments);
    } else if (call.method.equals("connectSFTP")) {
      connectSFTP((HashMap) call.arguments, result);
    } else if (call.method.equals("sftpLs")) {
      sftpLs((HashMap) call.arguments, result);
    } else if (call.method.equals("sftpRename")) {
      sftpRename((HashMap) call.arguments, result);
    } else if (call.method.equals("sftpMkdir")) {
      sftpMkdir((HashMap) call.arguments, result);
    } else if (call.method.equals("sftpRm")) {
      sftpRm((HashMap) call.arguments, result);
    } else if (call.method.equals("sftpRmdir")) {
      sftpRmdir((HashMap) call.arguments, result);
    } else if (call.method.equals("sftpDownload")) {
      sftpDownload((HashMap) call.arguments, result);
    } else if (call.method.equals("sftpUpload")) {
      sftpUpload((HashMap) call.arguments, result);
    } else if (call.method.equals("sftpCancelDownload")) {
      sftpCancelDownload((HashMap) call.arguments);
    } else if (call.method.equals("sftpCancelUpload")) {
      sftpCancelUpload((HashMap) call.arguments);
    } else if (call.method.equals("disconnectSFTP")) {
      disconnectSFTP((HashMap) call.arguments);
    } else if (call.method.equals("disconnect")) {
      disconnect((HashMap) call.arguments);
    } else {
      result.notImplemented();
    }
  }

  private class SSHClient {
    Session _session;
    String _key;
    BufferedReader _bufferedReader;
    DataOutputStream _dataOutputStream;
    Channel _channel = null;
    ChannelSftp _sftpSession = null;
    Boolean _downloadContinue = false;
    Boolean _uploadContinue = false;
  }

  private static final String LOGTAG = "SshPlugin";

  Map<String, SSHClient> clientPool = new HashMap<>();
  private EventSink eventSink;

  private SSHClient getClient(final String key, final Result result) {
    SSHClient client = clientPool.get(key);
    if (client == null)
      result.error("unknown_client", "Unknown client", null);
    return client;
  }

  @Override
  public void onListen(Object arguments, EventSink events) {
    this.eventSink = new MainThreadEventSink(events);
  }

  @Override
  public void onCancel(Object arguments) {
    this.eventSink = null;
  }

  private void connectToHost(final HashMap args, final Result result) {
    new Thread(new Runnable()  {
      public void run() {
        try {
          String key = args.get("id").toString();
          String host = args.get("host").toString();
          int port = (int)args.get("port");
          String username = args.get("username").toString();

          JSch jsch = new JSch();

          String password = "";
          if (args.get("passwordOrKey").getClass() == args.getClass()) {
            HashMap keyPairs = (HashMap) args.get("passwordOrKey");
            byte[] privateKey = keyPairs.containsKey("privateKey") ? keyPairs.get("privateKey").toString().getBytes(): null;
            byte[] publicKey = keyPairs.containsKey("publicKey") ? keyPairs.get("publicKey").toString().getBytes(): null;
            byte[] passphrase = keyPairs.containsKey("passphrase") ? keyPairs.get("passphrase").toString().getBytes(): null;
            jsch.addIdentity("default", privateKey, publicKey, passphrase);

          } else {
            password = args.get("passwordOrKey").toString();
          }

          Session session = jsch.getSession(username, host, port);

          if (password.length() > 0)
            session.setPassword(password);

          Properties properties = new Properties();
          properties.setProperty("StrictHostKeyChecking", "no");
          session.setConfig(properties);
          session.connect();

          if (session.isConnected()) {
            SSHClient client = new SSHClient();
            client._session = session;
            client._key = key;
            clientPool.put(key, client);

            Log.d(LOGTAG, "Session connected");
            result.success("session_connected");
          }
        } catch (Exception error) {
          Log.e(LOGTAG, "Connection failed: " + error.getMessage());
          result.error("connection_failure", error.getMessage(), null);
        }
      }
    }).start();
  }

  private void execute(final HashMap args, final Result result) {
    new Thread(new Runnable() {
      public void run() {
        try {
          SSHClient client = getClient(args.get("id").toString(), result);
          if (client == null)
            return;

          Session session = client._session;
          ChannelExec channel = (ChannelExec) session.openChannel("exec");
          channel.setCommand(args.get("cmd").toString());
          channel.connect();

          String line, response = "";
          InputStream in = channel.getInputStream();
          BufferedReader reader = new BufferedReader(new InputStreamReader(in));
          while ((line = reader.readLine()) != null) {
            response += line + "\r\n";
          }

          result.success(response);
        } catch (Exception error) {
          Log.e(LOGTAG, "Error executing command: " + error.getMessage());
          result.error("execute_failure", error.getMessage(), null);
        }
      }
    }).start();
  }
  
  private void portForwardL(final HashMap args, final Result result) {
    new Thread(new Runnable()  {
      public void run() {
        try {
          SSHClient client = getClient(args.get("id").toString(), result);
          if (client == null)
            return;
          
          Session session = client._session;
          int rport = Integer.parseInt(args.get("rport").toString());
          int lport = Integer.parseInt(args.get("lport").toString());
          String rhost = args.get("rhost").toString();
          int assinged_port=session.setPortForwardingL(lport, rhost, rport);
          
          result.success(Integer.toString(assinged_port));
        } catch (JSchException error) {
          Log.e(LOGTAG, "Error connecting portforwardL:" + error.getMessage());
          result.error("portforwardL_failure", error.getMessage(), null);
        }
      }
    }).start();
  }

  private void startShell(final HashMap args, final Result result) {
    new Thread(new Runnable()  {
      public void run() {
        try {
          String key = args.get("id").toString();
          SSHClient client = getClient(args.get("id").toString(), result);
          if (client == null)
            return;

          Session session = client._session;
          Channel channel = session.openChannel("shell");
          ((ChannelShell)channel).setPtyType(args.get("ptyType").toString());
          channel.connect();

          InputStream in = channel.getInputStream();
          client._channel = channel;
          client._bufferedReader = new BufferedReader(new InputStreamReader(in));
          client._dataOutputStream = new DataOutputStream(channel.getOutputStream());

          result.success("shell_started");

          String line;
          while (client._bufferedReader != null && (line = client._bufferedReader.readLine()) != null) {
            Map<String, Object> map = new HashMap<>();
            map.put("name", "Shell");
            map.put("key", key);
            map.put("value", line + '\n');
            sendEvent(map);
          }

        } catch (Exception error) {
          Log.e(LOGTAG, "Error starting shell: " + error.getMessage());
          result.error("shell_failure", error.getMessage(), null);
        }
      }
    }).start();
  }

  private void writeToShell(final HashMap args, final Result result) {
    new Thread(new Runnable()  {
      public void run() {
        try {
          SSHClient client = getClient(args.get("id").toString(), result);
          if (client == null)
            return;

          client._dataOutputStream.writeBytes(args.get("cmd").toString());
          client._dataOutputStream.flush();
          result.success("write_success");
        } catch (IOException error) {
          Log.e(LOGTAG, "Error writing to shell:" + error.getMessage());
          result.error("write_failure", error.getMessage(), null);
        }
      }
    }).start();
  }

  private void closeShell(final HashMap args) {
    new Thread(new Runnable()  {
      public void run() {
        try {
          SSHClient client = clientPool.get(args.get("id"));
          if (client == null)
            return;

          if (client._channel != null) {
            client._channel.disconnect();
          }

          if (client._dataOutputStream != null) {
            client._dataOutputStream.flush();
            client._dataOutputStream.close();
          }

          if (client._bufferedReader != null) {
            client._bufferedReader.close();
            client._bufferedReader = null;
          }
        } catch (IOException error) {
          Log.e(LOGTAG, "Error closing shell:" + error.getMessage());
        }
      }
    }).start();
  }

  private void connectSFTP(final HashMap args, final Result result) {
    new Thread(new Runnable()  {
      public void run() {
        try {
          SSHClient client = getClient(args.get("id").toString(), result);
          if (client == null)
            return;

          ChannelSftp channelSftp = (ChannelSftp) client._session.openChannel("sftp");
          channelSftp.connect();
          client._sftpSession = channelSftp;
          result.success("sftp_connected");
        } catch (JSchException error) {
          Log.e(LOGTAG, "Error connecting SFTP:" + error.getMessage());
          result.error("sftp_failure", error.getMessage(), null);
        }
      }
    }).start();
  }

  private void sftpLs(final HashMap args, final Result result) {
    new Thread(new Runnable()  {
      public void run() {
        try {
          SSHClient client = clientPool.get(args.get("id"));
          ChannelSftp channelSftp = client._sftpSession;

          Vector<LsEntry> files = channelSftp.ls(args.get("path").toString());
          List<Map<String, Object>> response = new ArrayList<>();

          for (LsEntry file: files) {
            String filename = file.getFilename();
            if (filename.trim().equals(".") || filename.trim().equals(".."))
              continue;

            Map<String, Object> f = new HashMap<>();
            f.put("filename", filename);
            f.put("isDirectory", file.getAttrs().isDir());
            Date datetime = new Date(file.getAttrs().getMTime() * 1000L);
            f.put("modificationDate", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(datetime));
            datetime = new Date(file.getAttrs().getATime() * 1000L);
            f.put("lastAccess", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(datetime));
            f.put("fileSize", file.getAttrs().getSize());
            f.put("ownerUserID", file.getAttrs().getUId());
            f.put("ownerGroupID", file.getAttrs().getGId());
            f.put("permissions", file.getAttrs().getPermissionsString());
            f.put("flags", file.getAttrs().getFlags());

            response.add(f);
          }
          result.success(response);
        } catch (SftpException error) {
          Log.e(LOGTAG, "Failed to list path " + error.getMessage());
          result.error("ls_failure", error.getMessage(), null);
        }
      }
    }).start();
  }

  private void sftpRename(final HashMap args, final Result result) {
    new Thread(new Runnable()  {
      public void run() {
        try {
          SSHClient client = clientPool.get(args.get("id"));
          ChannelSftp channelSftp = client._sftpSession;
          channelSftp.rename(args.get("oldPath").toString(), args.get("newPath").toString());
          result.success("rename_success");
        } catch (SftpException error) {
          Log.e(LOGTAG, "Failed to rename path " + args.get("oldPath").toString());
          result.error("rename_failure", error.getMessage(), null);
        }
      }
    }).start();
  }

  private void sftpMkdir(final HashMap args, final Result result) {
    new Thread(new Runnable()  {
      public void run() {
        try {
          SSHClient client = clientPool.get(args.get("id"));
          ChannelSftp channelSftp = client._sftpSession;
          channelSftp.mkdir(args.get("path").toString());
          result.success("mkdir_success");
        } catch (SftpException error) {
          Log.e(LOGTAG, "Failed to create directory " + args.get("path").toString());
          result.error("mkdir_success", error.getMessage(), null);
        }
      }
    }).start();
  }

  private void sftpRm(final HashMap args, final Result result) {
    new Thread(new Runnable()  {
      public void run() {
        try {
          SSHClient client = clientPool.get(args.get("id"));
          ChannelSftp channelSftp = client._sftpSession;
          channelSftp.rm(args.get("path").toString());
          result.success("rm_success");
        } catch (SftpException error) {
          Log.e(LOGTAG, "Failed to remove " + args.get("path").toString());
          result.error("rm_success", error.getMessage(), null);
        }
      }
    }).start();
  }

  private void sftpRmdir(final HashMap args, final Result result) {
    new Thread(new Runnable()  {
      public void run() {
        try {
          SSHClient client = clientPool.get(args.get("id"));
          ChannelSftp channelSftp = client._sftpSession;
          channelSftp.rmdir(args.get("path").toString());
          result.success("rmdir_success");
        } catch (SftpException error) {
          Log.e(LOGTAG, "Failed to remove " + args.get("path").toString());
          result.error("rmdir_failure", error.getMessage(), null);
        }
      }
    }).start();
  }

  private void sftpDownload(final HashMap args, final Result result) {
    new Thread(new Runnable()  {
      public void run() {
        try {
          SSHClient client = clientPool.get(args.get("id"));
          client._downloadContinue = true;
          ChannelSftp channelSftp = client._sftpSession;
          String path = args.get("path").toString();
          String toPath = args.get("toPath").toString();
          channelSftp.get(path, toPath, new progressMonitor(args.get("id").toString(), "DownloadProgress"));
          if (client._downloadContinue == true)
            result.success(toPath + '/' + (new File(path).getName()));
          else
            result.success("download_canceled");
        } catch (SftpException error) {
          Log.e(LOGTAG, "Failed to download " + args.get("path").toString());
          result.error("download_failure", error.getMessage(), null);
        }
      }
    }).start();
  }

  private void sftpUpload(final HashMap args, final Result result) {
    new Thread(new Runnable()  {
      public void run() {
        try {
          SSHClient client = clientPool.get(args.get("id"));
          client._uploadContinue = true;
          ChannelSftp channelSftp = client._sftpSession;
          String path = args.get("path").toString();
          String toPath = args.get("toPath").toString();
          channelSftp.put(path, toPath + '/' + (new File(path)).getName(),
              new progressMonitor(args.get("id").toString(), "UploadProgress"), ChannelSftp.OVERWRITE);
          if (client._uploadContinue == true)
            result.success("upload_success");
          else
            result.success("upload_canceled");
        } catch (SftpException error) {
          Log.e(LOGTAG, "Failed to upload " + args.get("path").toString());
          result.error("upload_failure", error.getMessage(), null);
        }
      }
    }).start();
  }

  private void sftpCancelDownload(final HashMap args) {
    SSHClient client = clientPool.get(args.get("id"));
    client._downloadContinue = false;
  }

  private void sftpCancelUpload(final HashMap args) {
    SSHClient client = clientPool.get(args.get("id"));
    client._uploadContinue = false;
  }

  private void disconnectSFTP(final HashMap args) {
    new Thread(new Runnable()  {
      public void run() {
        SSHClient client = clientPool.get(args.get("id"));
        if (client._sftpSession != null) {
          client._sftpSession.disconnect();
        }
      }
    }).start();
  }

  private void disconnect(final HashMap args) {
    this.closeShell(args);
    this.disconnectSFTP(args);

    SSHClient client = clientPool.get(args.get("id"));
    if (client == null)
      return;
    client._session.disconnect();
  }

  private void sendEvent(Map<String, Object> event) {
    if (eventSink != null)
      eventSink.success(event);
  }

  private class progressMonitor implements SftpProgressMonitor {
    private long max = 0;
    private long count = 0;
    private long completedPerc = 0;
    private String key;
    private String name;

    public progressMonitor(String key, String name) {
      this.key = key;
      this.name = name;
    }

    public void init(int arg0, String arg1, String arg2, long arg3) {
      this.max = arg3;
    }

    public boolean count(long arg0) {
      SSHClient client = clientPool.get(this.key);
      this.count += arg0;
      long newPerc = this.count * 100 / max;
      if(newPerc % 5 == 0 && newPerc > this.completedPerc) {
        this.completedPerc = newPerc;
        Map<String, Object> map = new HashMap<>();
        map.put("name", this.name);
        map.put("key", this.key);
        map.put("value", this.completedPerc);
        sendEvent(map);
      }
      boolean con;
      if (this.name.equals("DownloadProgress")) {
        con = client._downloadContinue;
      } else {
        con = client._uploadContinue;
      }
      return con;
    }

    public void end() {
    }
  }
}
