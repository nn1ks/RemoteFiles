#import "SshPlugin.h"

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)self.code]
                             message:self.domain
                             details:self.localizedDescription];
}
@end

@implementation SshPlugin  {
  NSMutableDictionary* _clientPool;
  FlutterEventSink _eventSink;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  SshPlugin* instance = [[SshPlugin alloc] init];
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"ssh"
            binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];
  
  FlutterEventChannel* shellChannel = [FlutterEventChannel
                                       eventChannelWithName:@"shell_sftp"
                                       binaryMessenger:[registrar messenger]];
  [shellChannel setStreamHandler:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary* args = call.arguments;
  if ([@"connectToHost" isEqualToString:call.method]) {
    NSNumber* port = args[@"port"];
    [self connectToHost:args[@"host"]
                   port:[port intValue]
           withUsername:args[@"username"]
          passwordOrKey:args[@"passwordOrKey"]
                withKey:args[@"id"] result:result];
  } else if ([@"execute" isEqualToString:call.method]) {
    [self execute:args[@"cmd"] withKey:args[@"id"] result:result];
  } else if ([@"startShell" isEqualToString:call.method]) {
    [self startShell:args[@"id"] ptyType:args[@"ptyType"] result:result];
  } else if ([@"writeToShell" isEqualToString:call.method]) {
    [self writeToShell:args[@"cmd"] withKey:args[@"id"] result:result];
  } else if ([@"closeShell" isEqualToString:call.method]) {
    [self closeShell:args[@"id"]];
  } else if ([@"connectSFTP" isEqualToString:call.method]) {
    [self connectSFTP:args[@"id"] result:result];
  } else if ([@"sftpLs" isEqualToString:call.method]) {
    [self sftpLs:args[@"path"] withKey:args[@"id"] result:result];
  } else if ([@"sftpRename" isEqualToString:call.method]) {
    [self sftpRename:args[@"oldPath"] newPath:args[@"newPath"] withKey:args[@"id"] result:result];
  } else if ([@"sftpMkdir" isEqualToString:call.method]) {
    [self sftpMkdir:args[@"path"] withKey:args[@"id"] result:result];
  } else if ([@"sftpRm" isEqualToString:call.method]) {
    [self sftpRm:call.arguments[@"path"] withKey:args[@"id"] result:result];
  } else if ([@"sftpRmdir" isEqualToString:call.method]) {
    [self sftpRmdir:args[@"path"] withKey:args[@"id"] result:result];
  } else if ([@"sftpDownload" isEqualToString:call.method]) {
    [self sftpDownload:args[@"path"] toPath:args[@"toPath"] withKey:args[@"id"] result:result];
  } else if ([@"sftpCancelDownload" isEqualToString:call.method]) {
    [self sftpCancelDownload:args[@"id"]];
  } else if ([@"sftpUpload" isEqualToString:call.method]) {
    [self sftpUpload:call.arguments[@"path"]
              toPath:call.arguments[@"toPath"]
             withKey:args[@"id"] result:result];
  } else if ([@"sftpCancelUpload" isEqualToString:call.method]) {
    [self sftpCancelUpload:args[@"id"]];
  } else if ([@"disconnectSFTP" isEqualToString:call.method]) {
    [self disconnectSFTP:args[@"id"]];
  } else if ([@"disconnect" isEqualToString:call.method]) {
    [self disconnect:args[@"id"]];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSMutableDictionary*) clientPool {
  if (!_clientPool) {
    _clientPool = [NSMutableDictionary new];
  }
  return _clientPool;
}

- (SSHClient*) clientForKey:(nonnull NSString*)key {
  return [[self clientPool] objectForKey:key];
}

- (BOOL)isConnected:(NMSSHSession *)session
             result:(FlutterResult)result {
  if (session && session.isConnected && session.isAuthorized) {
    return true;
  } else {
    NSLog(@"Session not connected");
    result([FlutterError errorWithCode:@"connection_failure" message:@"No connected session" details:nil]);
    return false;
  }
}

- (BOOL)isSFTPConnected:(NMSFTP *)sftpSesion
                 result:(FlutterResult)result {
  if (sftpSesion) {
    return true;
  } else {
    NSLog(@"SFTP not connected");
    result([FlutterError errorWithCode:@"sftp_failure" message:@"No sftp connection" details:nil]);
    return false;
  }
}

- (void)connectToHost:(NSString *)host
                 port:(int)port
         withUsername:(NSString *)username
        passwordOrKey:(id) passwordOrKey // password or {privateKey: value, [publicKey: value, passphrase: value]}
              withKey:(nonnull NSString*)key
               result:(FlutterResult)result {
  NMSSHSession* session = [NMSSHSession connectToHost:host
                                                 port:port
                                         withUsername:username];
  if (session && session.isConnected) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      if ([passwordOrKey isKindOfClass:[NSString class]])
        [session authenticateByPassword:passwordOrKey];
      else
        [session authenticateByInMemoryPublicKey:[passwordOrKey objectForKey:@"publicKey"]
                                      privateKey:[passwordOrKey objectForKey:@"privateKey"]
                                     andPassword:[passwordOrKey objectForKey:@"passphrase"]];
      
      if (session.isAuthorized) {
        SSHClient* client = [[SSHClient alloc] init];
        client._session = session;
        client._key = key;
        [[self clientPool] setObject:client forKey:key];
        NSLog(@"Session connected");
        result(@"session_connected");
      } else {
        NSLog(@"Authentication failed");
        result([FlutterError errorWithCode:@"auth_failure"
                                   message:[NSString stringWithFormat:@"Authentication to host %@ failed", host]
                                   details:nil]);
      }
    });
  } else {
    NSLog(@"Connection to host %@ failed", host);
    result([FlutterError errorWithCode:@"connection_failure"
                               message:[NSString stringWithFormat:@"Connection to host %@ failed", host]
                               details:nil]);
  }
}

- (void) execute:(NSString *)command
         withKey:(nonnull NSString*)key
          result:(FlutterResult)result {
  SSHClient* client = [self clientForKey:key];
  if (client) {
    NMSSHSession* session = client._session;
    if ([self isConnected:session result:result]) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError* error = nil;
        NSString* response = [session.channel execute:command error:&error timeout:@10];
        if (error) {
          NSLog(@"Error executing command: %@", error);
          result([error flutterError]);
        } else {
          result(response);
        }
      });
    }
  } else {
    result([FlutterError errorWithCode:@"unknown_client" message:@"Unknown client" details:nil]);
  }
}

- (void) startShell:(nonnull NSString*)key
            ptyType:(NSString *)ptyType // vanilla, vt100, vt102, vt220, ansi, xterm
             result:(FlutterResult)result {
  [self closeShell:key];
  SSHClient* client = [self clientForKey:key];
  if (client) {
    client.delegate = self;
    __block NSError *error = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [client startShell:ptyType error:&error];
      if (error) {
        NSLog(@"Error starting shell: %@", error);
        result([error flutterError]);
      } else {
        NSLog(@"Shell started");
        result(@"shell_started");
      }
    });
  } else {
    result([FlutterError errorWithCode:@"unknown_client" message:@"Unknown client" details:nil]);
  }
}

- (void) closeShell:(nonnull NSString*)key {
  SSHClient* client = [self clientForKey:key];
  if (client && client._session && client._session.channel) {
    [client._session.channel closeShell];
  }
}

- (void) writeToShell:(NSString *)command
              withKey:(nonnull NSString*)key
               result:(FlutterResult)result {
  SSHClient* client = [self clientForKey:key];
  if (client) {
    if ([self isConnected:client._session result:result]) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError* error = nil;
        [client._session.channel write:command error:&error timeout:@10];
        if (error) {
          NSLog(@"Error writing to shell: %@", error);
          result([error flutterError]);
        } else {
          NSLog(@"Write success");
          result(@"write_success");
        }
      });
    }
  } else {
    result([FlutterError errorWithCode:@"unknown_client" message:@"Unknown client" details:nil]);
  }
}

- (void) connectSFTP:(nonnull NSString*)key
              result:(FlutterResult)result {
  SSHClient* client = [self clientForKey:key];
  if (client) {
    if ([self isConnected:client._session result:result]) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NMSFTP* sftpSession = [NMSFTP connectWithSession:client._session];
        if (sftpSession) {
          client._sftpSession = sftpSession;
          NSLog(@"SFTP connected");
          result(@"sftp_connected");
        } else {
         result([FlutterError errorWithCode:@"sftp_failure" message:@"Failed to connect SFTP" details:nil]);
        }
      });
    }
  } else {
    result([FlutterError errorWithCode:@"unknown_client" message:@"Unknown client" details:nil]);
  }
}

- (void) sftpLs:(NSString *)path
        withKey:(nonnull NSString*)key
         result:(FlutterResult)result {
  SSHClient* client = [self clientForKey:key];
  if (client) {
    if ([self isConnected:client._session result:result] &&
        [self isSFTPConnected:client._sftpSession result:result]) {
      
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* fileList = [client._sftpSession contentsOfDirectoryAtPath:path];
        if (fileList) {
          NSMutableArray* array = [NSMutableArray array];
          NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
          [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
          for (NMSFTPFile* file in fileList) {
            NSMutableDictionary* res = [NSMutableDictionary dictionary];
            [res setObject:file.filename forKey:@"filename"];
            [res setObject:[NSNumber numberWithBool:file.isDirectory] forKey:@"isDirectory"];
            [res setObject:[formatter stringFromDate:file.modificationDate] forKey:@"modificationDate"];
            [res setObject:[formatter stringFromDate:file.lastAccess] forKey:@"lastAccess"];
            [res setObject:file.fileSize forKey:@"fileSize"];
            [res setObject:[NSNumber numberWithUnsignedLong:file.ownerUserID] forKey:@"ownerUserID"];
            [res setObject:[NSNumber numberWithUnsignedLong:file.ownerGroupID] forKey:@"ownerGroupID"];
            [res setObject:file.permissions forKey:@"permissions"];
            [res setObject:[NSNumber numberWithUnsignedLong:file.flags] forKey:@"flags"];
            [array addObject:res];
          }
          result(array);
        } else {
          result([FlutterError errorWithCode:@"ls_failure"
                                     message:[NSString stringWithFormat:@"Failed to list path  %@",path]
                                     details:nil]);
        }
      });
    } else {
      result([FlutterError errorWithCode:@"unknown_client" message:@"Unknown client" details:nil]);
    }
  }
}

- (void) sftpRename:(NSString *)oldPath
           newPath:(NSString *)newPath
           withKey:(nonnull NSString*)key
            result:(FlutterResult)result {
  SSHClient* client = [self clientForKey:key];
  if (client) {
    if ([self isConnected:client._session result:result] &&
        [self isSFTPConnected:client._sftpSession result:result]) {
      if ([client._sftpSession moveItemAtPath:oldPath toPath:newPath]) {
        NSLog(@"rename success");
        result(@"rename_success");
      } else {
        result([FlutterError errorWithCode:@"rename_failure"
                                   message:[NSString stringWithFormat:@"Failed to rename path %@ to %@", oldPath, newPath]
                                   details:nil]);
      }
    }
  } else {
    result([FlutterError errorWithCode:@"unknown_client" message:@"Unknown client" details:nil]);
  }
}

- (void) sftpMkdir:(NSString *)path
           withKey:(nonnull NSString*)key
            result:(FlutterResult)result {
  SSHClient* client = [self clientForKey:key];
  if (client) {
    if ([self isConnected:client._session result:result] &&
        [self isSFTPConnected:client._sftpSession result:result]) {
      if([client._sftpSession createDirectoryAtPath:path]) {
        NSLog(@"mkdir success");
        result(@"mkdir_success");
      } else {
        result([FlutterError errorWithCode:@"mkdir_failure"
                                   message:[NSString stringWithFormat:@"Failed to create directory %@", path]
                                   details:nil]);
      }
    }
  } else {
    result([FlutterError errorWithCode:@"unknown_client" message:@"Unknown client" details:nil]);
  }
}

- (void) sftpRm:(NSString *)path
        withKey:(nonnull NSString*)key
         result:(FlutterResult)result {
  SSHClient* client = [self clientForKey:key];
  if (client) {
    if ([self isConnected:client._session result:result] &&
        [self isSFTPConnected:client._sftpSession result:result]) {
      if([client._sftpSession removeFileAtPath:path]) {
        NSLog(@"rm success");
        result(@"rm_success");
      } else {
        result([FlutterError errorWithCode:@"rm_failure"
                                   message:[NSString stringWithFormat:@"Failed to remove %@", path]
                                   details:nil]);
      }
    }
  } else {
    result([FlutterError errorWithCode:@"unknown_client" message:@"Unknown client" details:nil]);
  }
}

- (void) sftpRmdir:(NSString *)path
           withKey:(nonnull NSString*)key
            result:(FlutterResult)result {
  SSHClient* client = [self clientForKey:key];
  if (client) {
    if ([self isConnected:client._session result:result] &&
        [self isSFTPConnected:client._sftpSession result:result]) {
      if([client._sftpSession removeDirectoryAtPath:path]) {
        NSLog(@"rmdir success");
        result(@"rmdir_success");
      } else {
        result([FlutterError errorWithCode:@"rmdir_failure"
                                   message:[NSString stringWithFormat:@"Failed to remove %@", path]
                                   details:nil]);
      }
    }
  } else {
    result([FlutterError errorWithCode:@"unknown_client" message:@"Unknown client" details:nil]);
  }
}

- (void) sftpDownload:(NSString *)path
               toPath:(NSString *)toPath
              withKey:(nonnull NSString*)key
               result:(FlutterResult)result{
  SSHClient* client = [self clientForKey:key];
  if (client) {
    if ([self isConnected:client._session result:result] &&
        [self isSFTPConnected:client._sftpSession result:result]) {
      NSString* filePath = [NSString stringWithFormat:@"%@/%@", toPath, [path lastPathComponent]];

      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        client.delegate = self;
        NSError* error = nil;
        [client sftpDownload:path toPath:filePath error:&error];
        if (error) {
          result([error flutterError]);
        } else if (client._downloadContinue) {
          result(filePath);
        } else {
          result(@"download_canceled");
        }
      });
    }
  } else {
    result([FlutterError errorWithCode:@"unknown_client" message:@"Unknown client" details:nil]);
  }
}

- (void) sftpUpload:(NSString *)filePath
             toPath:(NSString *)toPath
            withKey:(nonnull NSString*)key
             result:(FlutterResult)result {
  SSHClient* client = [self clientForKey:key];
  if (client) {
    if ([self isConnected:client._session result:result] &&
        [self isSFTPConnected:client._sftpSession result:result]) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        client.delegate = self;
        BOOL res = [client sftpUpload:filePath toPath:toPath];
        if (res) {
          result(@"upload_success");
        } else {
          if (client._uploadContinue) {
            NSLog(@"Error uploading file");
            result([FlutterError errorWithCode:@"upload_failure"
                                       message:[NSString stringWithFormat:@"Failed to upload %@ to %@", filePath, toPath]
                                       details:nil]);
          } else {
            result(@"upload_canceled");
          }
        }
      });
    }
  } else {
    result([FlutterError errorWithCode:@"unknown_client" message:@"Unknown client" details:nil]);
  }
}

- (void) sftpCancelDownload:(nonnull NSString*)key {
  SSHClient* client = [self clientForKey:key];
  if (client) {
    client._downloadContinue = false;
  }
}

- (void) sftpCancelUpload:(nonnull NSString*)key {
  SSHClient* client = [self clientForKey:key];
  if (client) {
    client._uploadContinue = false;
  }
}

- (void) disconnectSFTP:(nonnull NSString*)key {
  SSHClient* client = [self clientForKey:key];
  if (client && client._sftpSession) {
    [client._sftpSession disconnect];
  }
}

- (void) disconnect:(nonnull NSString*)key {
  [self closeShell:key];
  [self disconnectSFTP:key];
  SSHClient* client = [self clientForKey:key];
  if (client && client._session) {
    [client._session disconnect];
  }
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(FlutterEventSink)eventSink {
  _eventSink = eventSink;
  return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
  _eventSink = nil;
  return nil;
}

- (void) shellEvent:(NSString *)event withKey:(NSString *)key {
  if (!_eventSink) return;
  _eventSink(@{@"name": @"Shell", @"key": key, @"value": event});
}

- (void) downloadProgressEvent:(int)event withKey:(NSString *)key {
  if (!_eventSink) return;
  _eventSink(@{@"name": @"DownloadProgress", @"key": key, @"value": [NSNumber numberWithInt:event]});
}

- (void)uploadProgressEvent:(int)event withKey:(NSString *)key {
  if (!_eventSink) return;
  _eventSink(@{@"name": @"UploadProgress", @"key": key, @"value": [NSNumber numberWithInt:event]});
}

@end
