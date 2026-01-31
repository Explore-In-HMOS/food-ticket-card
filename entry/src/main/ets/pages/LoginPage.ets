import { ArcScrollBar } from '@ohos.arkui.ArcScrollBar';
import {
  ArcButton,
  ArcButtonOptions,
  ArcButtonStyleMode,
  ColorMetrics,
  LengthMetrics,
  LengthUnit
} from '@kit.ArkUI';
import { NotificationService } from '../service/NotificationService';
import { MOCK_CAMPAIGNS } from '../data/Campaign';

@Builder
export function LoginPageBuilder() {
  LoginPage()
}

@Entry
@ComponentV2
struct LoginPage {
  @Local okeyButton: ArcButtonOptions = new ArcButtonOptions({});
  pageInfo: NavPathStack = new NavPathStack();
  text: string = '';
  @Local enabledIndex: number = 0;
  scroller: Scroller = new Scroller();
  @Local validationMessage: string = '';

  isEmail(value: string): boolean {
    if (!value) {
      return false;
    }
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(value);
  }

  isPhone(value: string): boolean {
    if (!value) {
      return false;
    }
    const digits = value.replace(/\D/g, '');
    return /^\d{10}$/.test(digits);
  }

  calcScale(position: number): number {
    if (position === 0) {
      return 1.0;
    }
    if (position === 1) {
      return 0.85;
    }
    return 0.70;
  }

  build() {
    NavDestination() {
      Scroll(this.scroller) {
        Column() {
          Text($r('app.string.signin'))
            .fontSize(20 * this.calcScale(0))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.transaction_expense'))
            .textAlign(TextAlign.Center)
            .margin({ top: '10%' })
            .scale({ x: this.calcScale(0), y: this.calcScale(0) })
          Image($r('app.media.kawaii'))
            .width(`${30 * this.calcScale(0)}%`)
            .margin({ top: '4%', bottom: '4%' })
            .alignSelf(ItemAlign.Center)
          Text($r('app.string.welcome_text'))
            .fontSize(24 * this.calcScale(0))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.transaction_expense'))
            .textAlign(TextAlign.Center)
            .margin({ bottom: '2%' })
            .scale({ x: this.calcScale(1), y: this.calcScale(1) })
          Text($r('app.string.quick_text'))
            .fontSize(16 * this.calcScale(0))
            .fontColor($r('app.color.transaction_expense_gray'))
            .textAlign(TextAlign.Center)
            .margin({ bottom: '4%' })
            .scale({ x: this.calcScale(1), y: this.calcScale(1) })
          Text($r('app.string.email_phone_text'))
            .fontSize(16 * this.calcScale(1))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.transaction_expense'))
            .alignSelf(ItemAlign.Start)
            .margin({ left: '5%', bottom: '2%' })
            .scale({ x: this.calcScale(2), y: this.calcScale(2) })
          TextInput({ text: this.text!! })
            .fontSize(19 * this.calcScale(2))
            .fontColor($r('app.color.transaction_expense'))
            .borderColor($r('app.color.transaction_expense'))
            .borderWidth(1)
            .borderRadius(10)
            .size({ height: 75 * this.calcScale(2) })
            .scale({ x: this.calcScale(2), y: this.calcScale(2) })
            .margin({ bottom: '2%' })
            .onChange((value: string) => {
              this.text = value;
              this.validationMessage = '';
            })
          if (this.validationMessage !== '') {
            Text(this.validationMessage)
              .fontSize(10)
              .fontColor($r('app.color.error'))
              .margin(5)
          }
          ArcButton({
            options: new ArcButtonOptions({
              label: $r('app.string.ok_button'),
              styleMode: ArcButtonStyleMode.CUSTOM,
              fontSize: new LengthMetrics(14 * this.calcScale(1), LengthUnit.FP),
              fontColor: ColorMetrics.resourceColor($r('app.color.transaction_expense')),
              backgroundColor: ColorMetrics.resourceColor($r('app.color.input_border_focus')),
              onClick: () => {
                NotificationService.triggerSimpleNotification(MOCK_CAMPAIGNS[0]);
                const value = (this.text || '').trim();

                if (value === '') {
                  this.validationMessage = 'Enter phone or email.';
                  return;
                }

                if (value.includes('@')) {
                  if (this.isEmail(value)) {
                    this.pageInfo.pushPathByName('OTPPageBuilder', value);
                  } else {
                    this.validationMessage = 'Invalid E-mail address';
                  }
                } else {
                  if (this.isPhone(value)) {
                    const normalizedPhone = value.replace(/\D/g, '');
                    this.pageInfo.pushPathByName('OTPPageBuilder', normalizedPhone);
                  } else {
                    this.validationMessage = 'Invalid phone number';
                  }
                }
              }
            })
          })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .radialGradient({
        center: ['50%', '50%'],
        radius: '100%',
        repeating: false,
        colors: [
          [$r('app.color.success_background'), 0.2],
          [$r('app.color.background_primary'), 0.50],
          [0x000, 1.0]
        ]
      })
      .scrollBar(BarState.Off);

      ArcScrollBar({ scroller: this.scroller, state: BarState.Auto });
    }.onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack;
    })
    .hideToolBar(true)
    .hideBackButton(true)
    .hideTitleBar(true)
  }
}