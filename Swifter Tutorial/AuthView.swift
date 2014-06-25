// We need to import our frameworks used here
// UIKit is our base for interacting with nibs, storyboards, and the app as a whole
// The Accounts framework gives us access to accounts authed in the phone's settings
// The Social framework allows us to interact with twitter in a limited way
// The SwifteriOS framework gives us more granular control for dealing with twitter
import UIKit
import Accounts
import Social
import SwifteriOS

// our AuthView is assigned to the first UIViewController in the Main.storyboard
class AuthView: UIViewController
{
  // Default to using the iOS account framework for handling twitter auth
  let useACAccount = true
  
  // Our custom button action
  @IBAction func doTwitterLogin(sender : AnyObject)
  {
    // All errors should be caught and alert the user with user friendly text
    let failureHandler: ((NSError) -> Void) = {
      error in
      
      self.alert(error.localizedDescription)
    }
    
    // Use the accounts already stored in the phone's settings?
    if useACAccount
    {
      let accountStore = ACAccountStore()
      let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
      
      // Prompt the user for permission to their twitter account stored in the phone's settings
      accountStore.requestAccessToAccountsWithType(accountType) {
        granted, error in
        
        if granted
        {
          let twitterAccounts = accountStore.accountsWithAccountType(accountType)
          
          // We're thinking, why can't this be more dry? This is the only control flow where we beg for more
          // Would love to check: if twitterAccounts && twitterAccounts.count > 0
          if twitterAccounts
          {
            if twitterAccounts.count == 0
            {
              self.alert("There are no Twitter accounts configured. You can add or create a Twitter account in Settings.")
            }
            else
            {
              let twitterAccount = twitterAccounts[0] as ACAccount
              let swifter = Swifter(account: twitterAccount)
              self.fetchTwitterHomeStream(swifter)
            }
          }
          else {
            self.alert("There are no Twitter accounts configured. You can add or create a Twitter account in Settings.")
          }
        }
      }
    }
    // Let's do it the more typical way, by instantiating Swifter with our custom app credentials
    else
    {
      let swifter = Swifter(
        consumerKey: "RErEmzj7ijDkJr60ayE2gjSHT",
        consumerSecret: "SbS0CHk11oJdALARa7NDik0nty4pXvAxdt7aj0R5y1gNzWaNEx"
      )
      
      swifter.authorizeWithCallbackURL(
        NSURL(string: "swifter://success"),
        success: {
          accessToken, response in
          
          self.alert("Successfully authorized with App API")
          self.fetchTwitterHomeStream(swifter)
        },
        failure: failureHandler
      )
    }
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
  }
  
  // Keeping things DRY by creating a simple alert method that we can reuse for generic errors
  func alert(message: String)
  {
    // This is the iOS8 way of doing alerts. For older versions, look into UIAlertView
    var alert = UIAlertController(
      title: nil,
      message: message,
      preferredStyle: UIAlertControllerStyle.Alert
    )
    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  // More DRY code, fetch the users home timeline if all went well
  func fetchTwitterHomeStream(swifter: Swifter)
  {
    let failureHandler: ((NSError) -> Void) = {
      error in
      self.alert(error.localizedDescription)
    }
    
    swifter.getStatusesHomeTimelineWithCount(
      20,
      sinceID: nil,
      maxID: nil,
      trimUser: true,
      contributorDetails: false,
      includeEntities: true,
      success: {
        statuses, response in
        
        // We loaded the stream just fine, so lets create and push the table view
        let recentTweets = self.storyboard.instantiateViewControllerWithIdentifier("RecentTweets") as RecentTweets
        recentTweets.recentTweets = statuses as NSArray
        self.presentViewController(recentTweets, animated: true, completion: nil)
      },
      failure: failureHandler
    )
    
  }
}