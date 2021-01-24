// Project imports:
import 'package:syphon/global/values.dart';

/**
 * Will be converted to
 * i18n json soon, but a "String" 
 * class below is just a stub for now
 */
class Strings {
  // View Titles
  static const titleProfile = 'Set up Your Profile';
  static const titleSettings = 'Settings';
  static const titleAdvanced = 'Advanced';
  static const titleInvite = 'Invite';
  static const titleSearchGroups = 'Explore Groups';
  static const titleSearchUsers = 'Search Users';
  static const titleInviteusers = 'Invite Users';
  static const titleRoomUsers = 'All Room Users';
  static const titleCreateGroup = 'Create A Group Chat';
  static const titleCreateGroupPublic = 'Create A Public Group';

  // Dialog Titles
  static const titleDialogDeleteKeys = 'Confirm Deleting Keys';
  static const titleDialogEncryption = 'Encrypt Chat?';
  static const titleDialogCaptcha = 'Complete Captcha';
  static const titleDialogTerms = "Confirm Terms Of Service";
  static const titleDialogTermsAlpha = 'Confirm Open Alpha Terms Of Service';
  static const titleDialogEmailRequirement = 'Email requirement';
  static const titleDialogEmailVerifiedRequirement = 'Email verification';

  // Placeholders
  static const placeholderHomeserverSearch = 'Search for homeservers...';

  // Labels
  static const labelSearchForHomeservers = "Search for homeservers...";
  static const labelSearchForUsers = 'Search for a user...';
  static const labelSearchedUsers = 'Matched Users';
  static const labelUsersSection = 'Users';
  static const labelRecentUsers = 'Recent Users';
  static const labelRoomNameDefault = 'New Chat';
  static const labelNoMessages = 'no messages found';
  static const labelDeletedMessage = 'This message was deleted';

  // Buttons
  static const buttonLogin = 'log in';
  static const buttonLoginSSO = 'single sign on';
  static const buttonSaveGeneric = 'save';
  static const buttonSendVerification = 'send verification email';
  static const buttonSignupNext = 'continue';
  static const buttonSignupFinish = 'finish';
  static const buttonLetsChat = 'let\'s chat';
  static const buttonCreate = 'create';
  static const buttonCancel = 'cancel';
  static const buttonQuit = 'quit';
  static const buttonConfirm = 'got it';
  static const buttonConfirmAlt = 'ok';
  static const buttonBlocKUser = 'block user';
  static const buttonDeleteKeys = 'delete keys';

  // Text Buttons
  static const buttonTextSignup = "button-text-signup";

  static const buttonTextSeeAllUsers = 'See All Users';
  static const buttonIntroExistQuestion = 'Already have a username?';
  static const buttonIntroExistAction = 'Login';
  static const buttonLoginCreateQuestion = 'Don\'t have a username?';
  static const buttonLoginCreateAction = 'Create One';
  static const buttonTextLogin = 'Login';

  // Errors
  static const alertInviteUnknownUser =
      'This user doens\'t appear to exist within matrix, but you can attempt to invite them anyway.\n\nMake sure you have the correct name before trying.';
  static const errorMessageSendingFailed = 'Message Failed To Send';
  static const errorCheckHomeserver =
      'This server failed the \'well-known\' check, make sure the server is configured correctly';

  // intro
  static const contentIntroFirstPartOne =
      '${Values.appName} works by using an encrypted \nand decentralized protocol \ncalled ';

  static const contentIntroSecondPartOne =
      'Matrix enables you to message others \nwith';
  static const contentIntroSecondPartBold = 'privacy and control ';
  static const contentIntroSecondPartTwo = 'where the\nmessages are stored';

  static const contentIntroThird =
      'Both Matrix and ${Values.appName} are developed\nopenly by organizations and people,\nnot corporations';

  static const contentIntroFinal =
      'By using ${Values.appName} and other Matrix clients\nwe can make private messaging \naccessible to everyone';

  static const contentNotificationBackgroundService =
      'Background connection enabled';

  // Content
  static const contentDeleteDevices =
      'You will have to sign in again on these devices if you remove them.';

  static const contentDeleteDeviceKeyWarning =
      "Are you sure you want to export this devices encryption key? It may make it available to others if you're not careful!";
  static const contentEncryptedMessage = 'Encrypted Message';

  static const contentEmailRequirement =
      'This homeserver requires an email for registration, your email will be visible to whoever or whatever is in control of the homeserver. Make sure you trust this homeserver before submitting this information';

  static const contentVerifyPasswordReset =
      'A verification email will be sent to your inbox before resetting your password. After verification, you\'ll be able to set and confirm a new password.';

  static const contentEmailVerifiedRequirement =
      'This homeserver requires a verified email to complete registration, you\'ll need to click the link in the email address to continue. Make sure you trust this homeserver before clicking the verification link.';

  // Confirmations
  static const confirmationDeleteKeys =
      "Are you sure you want to delete your encryption keys for this device? This is very destructive and will probably render all your encrypted messages undecryptable.";

  static const confirmationInvite =
      'Are you sure you want to invite the following user to the following room?';

  static const confirmationInvites =
      'Are you sure you want to invite the selected users to the following room?';

  static const confirmationStartChat = 'Even if you don\'t send a message, ' +
      'the user will still see your invite to chat.';
  static const confirmationAttemptChat = 'Even if you don\'t send a message, ' +
      'the user will still see your invite to chat if they exist.\n\nDo you want to try chatting with this username?';
  static const confirmationAppTermsOfService =
      'THIS SOFTWARE (${Values.appName}) IS PROVIDED BY THE AUTHOR \'\'AS IS\'\' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.';
  static const confirmationNotifications =
      'Your device will prompt you to turn on notifications for ${Values.appName}.\n\nDo you want to turn on message notifications?';
  static const confirmationInteractiveAuth =
      'In order to perform this action, you\'ll need to enter your password again';

  static const confirmationThanks =
      'Thanks for trying out ${Values.appName}!\n\n';

  static const confirmationAlphaVersion =
      'Please be aware this app is still very much in Alpha.\n';

  static const confirmationAlphaWarning =
      'Do not use, nor do I recommend using, Syphon where proven and independently verified security is required.\n';

  static const confirmationAlphaWarningAlt =
      'You may lose data using this application as features and bugs are worked out.\n';

  static const confirmationConclusion =
      'Please read the below terms and conditions for this application and if you agree tap "I Agree" to continue:\n\n';

  static const confirmationAcceptInvite =
      'If you accept this room invite, the users in the room will be made aware you\'ve accepted. Are you sure you want to accept now?';

  static const confirmationEncryption =
      'After you encrypt a chat, you cannot go back to sending messages unencrypted. Are you sure you want to encrypt this chat?';

  static const confirmationGroupEncryption =
      'After you encrypt a chat, you cannot go back to sending messages unencrypted. Are you sure you want to encrypt this group chat?\n\nPlease be aware Group E2EE is still a work in progress. You may lose message data!';

  // Placeholders
  static const placeholderInputMatrixUnencrypted =
      'Matrix message (unencrypted)';
  static const placeholderInputMatrixEncrypted = 'Matrix message';

  static String formatUsernameHint({String homeserver, String username}) {
    return homeserver.length != 0
        ? '@${username != null && username.length > 0 ? username : 'username'}:$homeserver'
        : '@${username != null && username.length > 0 ? username : 'username'}:matrix.org';
  }

  // Tooltips
  static const tooltipSelectHomeserver = 'Select your usernames homeserver';

  // Accessibility
  static const semanticsPrivateMessage =
      'A person holding up a private message';
  static const semanticsSendUnencrypted = 'Send unencrypted message';
  static const semanticsIntroFinal =
      'Two different people feeling confident and lookin\' good';
  static const semanticsIntroThird = 'People lounging around and messaging';
  static const semanticsLabelImageIntro = 'Relaxed, Lounging User';
  static const semanticsLabelHomeEmpty =
      'Tiny cute monsters hidding behind foliage';
}
