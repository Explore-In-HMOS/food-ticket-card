import { LoginPageBuilder } from './LoginPage';
import { MainPageBuilder } from './MainPage';
import { OTPPageBuilder } from './OTPPage';
import { PaymentPageBuilder } from './PaymentPage';
import { PlusPayPageBuilder } from './PlusPayPage';
import { NotificationService } from '../service/NotificationService';
import { MOCK_CAMPAIGNS } from '../data/Campaign';
import { NfcPayPageBuilder } from './NFCPaymentPage';

@Entry
@Component
struct Index {
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();

  private campaignTimer: number | undefined = undefined;
  private campaignIdx: number = 0;
  private startCampaignTicker(): void {
    this.campaignTimer = setInterval(() => {
      const campaign = MOCK_CAMPAIGNS[this.campaignIdx % MOCK_CAMPAIGNS.length];
      NotificationService.triggerSimpleNotification(campaign);
      this.campaignIdx++;
    }, 30000) as number;
  }

  @Builder
  pages(name: string, text : string) {
    if (name === 'LoginPageBuilder') {
      LoginPageBuilder();
    } else if (name === 'OTPPageBuilder') {
      OTPPageBuilder(text);
    } else if (name === 'MainPageBuilder') {
      MainPageBuilder();
    } else if (name === 'PaymentPageBuilder') {
      PaymentPageBuilder();
    } else if (name === 'PlusPayPageBuilder') {
      PlusPayPageBuilder();
    } else if (name === 'NfcPayPageBuilder') {
      NfcPayPageBuilder();
    }
  }

  build() {
    Navigation(this.pageStack)
      .mode(NavigationMode.Stack)
      .navDestination(this.pages)
      .hideNavBar(true)
      .onAppear(() => {
        if (this.pageStack.getAllPathName().length === 0) {
          this.pageStack.pushPathByName('LoginPageBuilder', null);
        }
        this.startCampaignTicker();
      })
  }
}