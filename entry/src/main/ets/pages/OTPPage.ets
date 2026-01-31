import {
  ArcButton,
  ArcButtonOptions,
  ArcButtonStyleMode,
  ColorMetrics,
  LengthMetrics,
  LengthUnit
} from '@kit.ArkUI';

@Builder
export function OTPPageBuilder(text: string) {
  OTPPage({ text })
}

@Entry
@ComponentV2
struct OTPPage {
  pageInfo: NavPathStack = new NavPathStack();
  @Local okeyButton: ArcButtonOptions = new ArcButtonOptions({});
  @Param text: string = '';
  @Local otpValue: string = '';
  @Local shake: boolean = false;
  @Local remainingTime: number = 30;
  @Local timerActive: boolean = true;
  @Local private intervalId: number = 0;
  private keys: number[] = [0, 1, 2, 3, 4, 5];

  calcScale(position: number): number {
    if (position === 0) {
      return 1.0;
    }
    if (position === 1) {
      return 0.85;
    }
    return 0.70;
  }

  formatPhoneNumber(text: string): string {
    if (!text.includes('@')) {
      return 'Enter the 6-digit code sent to your phone number.';
    } else {
      return `Enter the 6-digit code sent to the address ${text}`;
    }
  }

  private onOtpChange(value: string) {
    if (value.length > 6) {
      this.otpValue = value.substring(0, 6);
    } else {
      this.otpValue = value;
    }
  }

  private triggerWrongCodeAnimation() {
    this.shake = true;
    setTimeout(() => {
      this.shake = false;
      this.otpValue = '';
    }, 400);
  }

  private startTimer() {
    this.timerActive = true;
    this.remainingTime = 30;

    this.intervalId = setInterval(() => {
      if (this.remainingTime > 0) {
        this.remainingTime--;
      } else {
        this.timerActive = false;
        clearInterval(this.intervalId);
      }
    }, 1000);
  }

  aboutToAppear() {
    this.startTimer();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Text($r('app.string.verify_text'))
            .fontSize(20 * this.calcScale(0))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.transaction_expense'))
            .textAlign(TextAlign.Center)
            .margin({ top: '10%', bottom: '6%' })
            .scale({ x: this.calcScale(0), y: this.calcScale(0) })

          Text($r('app.string.6_digit_text'))
            .fontSize(20 * this.calcScale(1))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.transaction_expense'))
            .textAlign(TextAlign.Center)
            .margin({ bottom: '2%' })
            .scale({ x: this.calcScale(1), y: this.calcScale(1) })

          Text(this.formatPhoneNumber(this.text))
            .fontSize(16 * this.calcScale(1))
            .fontColor($r('app.color.transaction_expense_gray'))
            .textAlign(TextAlign.Center)
            .margin({ left: '8%', right: '8%' })
            .scale({ x: this.calcScale(1), y: this.calcScale(1) })

          TextInput({
            text: this.otpValue,
            placeholder: ''
          })
            .type(InputType.Number)
            .maxLength(6)
            .opacity(0.01)
            .height(0)
            .width('80%')
            .focusable(true)
            .id('ti')
            .onChange((value: string) => this.onOtpChange(value))

          Row() {
            ForEach(this.keys, (item: number) => {
              Column() {
                Text(this.otpValue[item] ?? '')
                  .fontSize(20 * this.calcScale(1))
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Center)
                  .fontColor($r('app.color.border_emphasis'))
                  .width('100%')
                  .height('100%')
              }
              .width(28)
              .height(36)
              .margin(3)
              .border({
                width: 2,
                color: this.otpValue.length === item ? $r('app.color.border_emphasis') :
                $r('app.color.transaction_expense_dark_gray')
              })
              .borderRadius(6)
              .backgroundColor($r('app.color.button_disabled_text'))
            }, (item: number) => item.toString());
          }
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: '6%' })
          .onClick(() => {
            focusControl.requestFocus('ti');
          })

          Text(
            this.timerActive ? `Remining time: ${this.remainingTime} second` : 'Time is over'
          )
            .fontSize(20 * this.calcScale(1))
            .fontColor($r('app.color.transaction_expense_gray'))
            .margin({ bottom: '4%' })
            .scale({ x: this.calcScale(2), y: this.calcScale(2) })

          Text('Get new code')
            .fontSize(20 * this.calcScale(1))
            .fontColor(this.timerActive ? $r('app.color.transaction_expense_dark_gray') :
            $r('app.color.input_border_focus'))
            .opacity(this.timerActive ? 0.4 : 1)
            .margin({ bottom: '10%' })
            .scale({ x: this.calcScale(2), y: this.calcScale(2) })
            .onClick(() => {
              if (!this.timerActive) {
                this.startTimer();
              }
            })
          ArcButton(
            {
              options: new ArcButtonOptions({
                label: $r('app.string.ok_button'),
                styleMode: ArcButtonStyleMode.CUSTOM,
                fontSize: new LengthMetrics(14 * this.calcScale(1), LengthUnit.FP),
                fontColor: ColorMetrics.resourceColor($r('app.color.transaction_expense')),
                backgroundColor: ColorMetrics.resourceColor($r('app.color.input_border_focus')),
                onClick: () => {
                  if (this.otpValue !== '123456') {
                    this.triggerWrongCodeAnimation();
                  } else {
                    this.pageInfo.pushPathByName('MainPageBuilder', null);
                  }
                }
              })
            }
          )
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .radialGradient({
        center: ['50%', '50%'],
        radius: '100%',
        repeating: false, // The gradients are not repeated.
        colors: [
          [$r('app.color.success_background'), 0.2],
          [$r('app.color.background_primary'), 0.50],
          [0x000, 1.0]
        ]
      })
      .scrollBar(BarState.Off)
    }.onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack;
    })
    .hideToolBar(true)
    .hideBackButton(true)
    .hideTitleBar(true)
  }
}
