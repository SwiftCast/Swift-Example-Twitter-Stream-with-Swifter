import UIKit
import Accounts
import Social
import SwifteriOS

class AuthViewController: UIViewController
{
  let useACAccount = true
  
  @IBAction func doTwitterLogin(sender : AnyObject)
  {
    let failureHandler: ((NSError) -> Void) = {
      error in
      
      self.alert(error.localizedDescription)
    }
    
    if useACAccount
    {
      let accountStore = ACAccountStore()
      let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
      
      accountStore.requestAccessToAccountsWithType(accountType) {
        granted, error in
        
        if granted
        {
          let twitterAccounts = accountStore.accountsWithAccountType(accountType)
          
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
      ) // switfer.authorizeWithCallbackURL
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
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
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
        println(statuses)
      },
      failure: failureHandler
    )
  }
}