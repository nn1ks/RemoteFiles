#import <NMSSH/NMSSH.h>

@protocol SSHClientDelegate <NSObject>
- (void) shellEvent:(NSString *)event withKey:(NSString *)key;
- (void) downloadProgressEvent:(int)event withKey:(NSString *)key;
- (void) uploadProgressEvent:(int)event withKey:(NSString *)key;
@end

@interface SSHClient: NSObject <NMSSHChannelDelegate>
    @property(nonatomic, retain) NMSSHSession* _session;
    @property(nonatomic, retain) NMSFTP* _sftpSession;
    @property(nonatomic, retain) NSString* _key;
    @property (assign) BOOL _downloadContinue;
    @property (assign) BOOL _uploadContinue;

    @property (nonatomic, weak) id <SSHClientDelegate> delegate;

- (void) startShell:(NSString *)ptyType error:(NSError **)error;
- (void) sftpDownload:(NSString *)path toPath:(NSString *)filePath error:(NSError **)error;
- (BOOL) sftpUpload:(NSString *)filePath toPath:(NSString *)path;
@end
