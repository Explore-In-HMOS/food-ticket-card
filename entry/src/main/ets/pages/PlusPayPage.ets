import {
  ArcButton,
  ArcButtonOptions,
  ArcButtonStyleMode,
  ColorMetrics,
  LengthMetrics,
  LengthUnit
} from '@kit.ArkUI';
import { PaymentViewModel } from '../service/GenerateCodeService';

@Builder
export function PlusPayPageBuilder(): void {
  PlusPayPage();
}

@Component
struct PlusPayPage {
  pageInfo: NavPathStack = new NavPathStack();
  @State vm: PaymentViewModel = new PaymentViewModel();
  @State remainingMs: number = 0;
  @State progressValue: number = 100;
  private timerId: number | undefined = 0;
  private totalMs: number = 30000;

  calcScale(position: number): number {
    if (position === 0) {
      return 1.0;
    }
    if (position === 1) {
      return 0.85;
    }
    return 0.70;
  }

  aboutToAppear(): void {
    this.vm.generateCode();
    this.remainingMs = this.totalMs;
    this.updateProgress();
    this.startCountdown();
  }

  aboutToDisappear(): void {
    this.stopCountdown();
  }

  private startCountdown(): void {
    this.stopCountdown();
    this.timerId = setInterval(() => {
      this.remainingMs = Math.max(0, this.remainingMs - 100);
      this.updateProgress();
      if (this.remainingMs <= 0) {
        this.stopCountdown();
      }
    }, 100);
  }

  private stopCountdown(): void {
    if (this.timerId !== undefined) {
      clearInterval(this.timerId);
      this.timerId = undefined;
    }
  }

  private updateProgress(): void {
    if (this.totalMs <= 0) {
      this.progressValue = 0;
      return;
    }
    this.progressValue = Math.floor((this.remainingMs / this.totalMs) * 100);
  }

  private goBack(): void {
    this.pageInfo.pop();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {

          Text('PlusPay')
            .fontSize(20 * this.calcScale(0))
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .textAlign(TextAlign.Center)
            .margin({ top: '12%', bottom: '6%' })
            .scale({ x: this.calcScale(0), y: this.calcScale(0) });

          Text($r('app.string.PlusPay_Title'))
            .fontSize(16 * this.calcScale(1))
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .textAlign(TextAlign.Center)
            .margin({ bottom: '2%' })
            .scale({ x: this.calcScale(1), y: this.calcScale(1) });

          Row() {
            Text($r('app.string.Otp_Label'))
              .fontSize(14 * this.calcScale(1))
              .fontColor('#CCCCCC');
            Text(': ')
              .fontSize(14 * this.calcScale(1))
              .fontColor('#CCCCCC');
            Text(this.vm.paymentCode)
              .fontSize(16 * this.calcScale(1))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.input_border_focus'));
          }
          .margin({ bottom: '6%' })
          .justifyContent(FlexAlign.Center);

          Progress({ value: this.progressValue, total: 100, type: ProgressType.Linear })
            .width('70%')
            .height(10)
            .alignSelf(ItemAlign.Center)
            .color($r('app.color.input_border_focus'))
            .backgroundColor('#333A55')
            .margin({ bottom: '6%' });

          Row() {
            Text($r('app.string.Remaining_Time_Label'))
              .fontSize(12 * this.calcScale(2))
              .fontColor('#CCCCCC');
            Text(': ')
              .fontSize(12 * this.calcScale(2))
              .fontColor('#CCCCCC');
            Text(`${Math.ceil(this.remainingMs / 1000)} s`)
              .fontSize(12 * this.calcScale(2))
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF');
          }
          .margin({ bottom: '8%' })
          .justifyContent(FlexAlign.Center);

          Row() {
            QRCode(this.vm.paymentCode)
              .width('55%')
              .aspectRatio(1)
              .alignSelf(ItemAlign.Center);
          }
          .padding(6)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: '10%' })
          .justifyContent(FlexAlign.Center);

          ArcButton(
            {
              options: new ArcButtonOptions({
                label: 'Back',
                styleMode: ArcButtonStyleMode.CUSTOM,
                fontSize: new LengthMetrics(14 * this.calcScale(1), LengthUnit.FP),
                fontColor: ColorMetrics.resourceColor($r('app.color.transaction_expense')),
                backgroundColor: ColorMetrics.resourceColor($r('app.color.input_border_focus')),
                onClick: () => {
                  this.goBack();
                }
              })
            });
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center);
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
      }).scrollBar(BarState.Off);
    }
    .onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack;
    })
    .hideToolBar(true)
    .hideBackButton(true)
    .hideTitleBar(true);
  }
}
