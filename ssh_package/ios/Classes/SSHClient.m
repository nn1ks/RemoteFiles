#import "SSHClient.h"

@implementation SSHClient

@synthesize delegate;

@synthesize _session = _session;
@synthesize _sftpSession = _sftpSession;
@synthesize _downloadContinue = _downloadContinue;
@synthesize _uploadContinue = _uploadContinue;
@synthesize _key = _key;

int downloadedPerc = 0;
int uploadedPerc = 0;

- (instancetype)init {
  if ((self = [super init])) {
    _session = [NMSSHSession alloc];
    _sftpSession = [[NMSFTP alloc] init];
    _key = [[NSString alloc] init];
    _downloadContinue = false;
    _uploadContinue = false;
  }
  return self;
}

- (void) startShell:(NSString *)ptyType error:(NSError * __autoreleasing *)error  {
  NMSSHChannelPtyTerminal type;
  NMSSHChannel *channel = _session.channel;
  channel.delegate = self;
  channel.requestPty = YES;
  
  NSArray *items = @[@"vanilla", @"vt100", @"vt102", @"vt220", @"ansi", @"xterm"];
  NSUInteger item = [items indexOfObject:ptyType];
  switch (item) {
    case 0:
      type = NMSSHChannelPtyTerminalVanilla;
      break;
    case 1:
      type = NMSSHChannelPtyTerminalVT100;
      break;
    case 2:
      type = NMSSHChannelPtyTerminalVT102;
      break;
    case 3:
      type = NMSSHChannelPtyTerminalVT220;
      break;
    case 4:
      type = NMSSHChannelPtyTerminalAnsi;
      break;
    default:
      type = NMSSHChannelPtyTerminalXterm;
      break;
  }
  
  channel.ptyTerminalType = type;
  dispatch_async(dispatch_get_main_queue(), ^
  {
    [channel startShell:error];
  });
}

- (void)channel:(NMSSHChannel *)channel didReadData:(NSString *)message {
  [self.delegate shellEvent:message withKey:_key];
}

- (void)channel:(NMSSHChannel *)channel didReadError:(NSString *)error {
  [self.delegate shellEvent:error withKey:_key];
}

- (void) sftpDownload:(NSString *)path toPath:(NSString *)filePath error:(NSError **)error {
  _downloadContinue = true;
  downloadedPerc = 0;
  NSData* data = [_sftpSession contentsAtPath:path progress: ^BOOL (NSUInteger bytes, NSUInteger fileSize) {
    int newPerc = (int)(100.0f * bytes / fileSize);
    if (newPerc % 5 == 0 && newPerc > downloadedPerc) {
      downloadedPerc = newPerc;
      [self.delegate downloadProgressEvent:downloadedPerc withKey:self->_key];
    }
    return self->_downloadContinue;
  }];
  if (data) {
    [data writeToFile:filePath options:NSDataWritingAtomic error:error];
  }
}

- (BOOL) sftpUpload:(NSString *)filePath toPath:(NSString *)path {
  _uploadContinue = true;
  uploadedPerc = 0;
  NSString *newPath = [NSString stringWithFormat:@"%@/%@",path, [filePath lastPathComponent]];
  long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil][NSFileSize] longLongValue];
  BOOL result = [self._sftpSession writeFileAtPath:filePath toFileAtPath:newPath progress: ^BOOL (NSUInteger bytes) {
    int newPerc = (int)(100.0f * bytes / fileSize);
    if (newPerc % 5 == 0 && newPerc > uploadedPerc) {
      uploadedPerc = newPerc;
      [self.delegate uploadProgressEvent:uploadedPerc withKey:self->_key];
    }
    return self->_uploadContinue;
  }];
  return result;
}

@end
