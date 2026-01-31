@Builder
export function PaymentPageBuilder(): void {
  PaymentPage();
}

@Entry
@Component
struct PaymentPage {
  pageInfo: NavPathStack = new NavPathStack();
  private showNfcStatus: boolean = false;
  private showNfcContextError: boolean = false;

  calcScale(position: number): number {
    if (position === 0) {
      return 1.0;
    }
    if (position === 1) {
      return 0.85;
    }
    return 0.70;
  }

  private startNfcPayment(): void {
    this.pageInfo.pushPathByName('NfcPayPageBuilder', null);
  }

  private gotoPlusPayPage(): void {
    this.pageInfo.pushPathByName('PlusPayPageBuilder', null);
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {

          Text('Payment Type')
            .fontSize(20 * this.calcScale(0))
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .textAlign(TextAlign.Center)
            .margin({ top: '12%', bottom: '6%' })
            .scale({ x: this.calcScale(0), y: this.calcScale(0) })

          Image($r('app.media.kawaii'))
            .width(`${35 * this.calcScale(0)}%`)
            .margin({ top: '4%', bottom: '4%' })
            .alignSelf(ItemAlign.Center)
            .scale({ x: this.calcScale(0), y: this.calcScale(0) })

          Text($r('app.string.Payment_Select_Method'))
            .fontSize(16 * this.calcScale(1))
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .textAlign(TextAlign.Center)
            .margin({ bottom: '2%' })
            .scale({ x: this.calcScale(1), y: this.calcScale(1) })

          Text($r('app.string.Payment_Explain_Text'))
            .fontSize(12 * this.calcScale(1))
            .fontColor('#CCCCCC')
            .textAlign(TextAlign.Center)
            .margin({ left: '8%', right: '8%', bottom: '8%' })
            .scale({ x: this.calcScale(1), y: this.calcScale(1) })

          Button($r('app.string.Pay_With_Plus'), { type: ButtonType.Normal })
            .fontSize(14 * this.calcScale(1))
            .backgroundColor($r('app.color.input_border_focus'))
            .fontColor('#FFFFFF')
            .borderRadius(16)
            .margin({ bottom: '6%' })
            .size({ height: 48 * this.calcScale(1), width: '70%' })
            .alignSelf(ItemAlign.Center)
            .scale({ x: this.calcScale(1), y: this.calcScale(1) })
            .onClick(() => this.gotoPlusPayPage())

          Button($r('app.string.Pay_With_NFC'), { type: ButtonType.Normal })
            .fontSize(14 * this.calcScale(1))
            .backgroundColor($r('app.color.input_border_focus'))
            .fontColor('#FFFFFF')
            .borderRadius(16)
            .margin({ bottom: '6%' })
            .size({ height: 48 * this.calcScale(1), width: '70%' })
            .alignSelf(ItemAlign.Center)
            .scale({ x: this.calcScale(1), y: this.calcScale(1) })
            .onClick(() => this.startNfcPayment())

          if (this.showNfcStatus) {
            Text($r('app.string.Nfc_Started_Status_Message'))
              .fontSize(12 * this.calcScale(2))
              .fontColor('#FFFFFF')
              .textAlign(TextAlign.Center)
              .margin({ bottom: '4%', left: '8%', right: '8%' })
              .scale({ x: this.calcScale(2), y: this.calcScale(2) })
          }

          if (this.showNfcContextError) {
            Text($r('app.string.Nfc_Context_Error_Message'))
              .fontSize(12 * this.calcScale(2))
              .fontColor('#FF6B6B')
              .textAlign(TextAlign.Center)
              .margin({ bottom: '4%', left: '8%', right: '8%' })
              .scale({ x: this.calcScale(2), y: this.calcScale(2) })
          }

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
      .scrollBar(BarState.Off)
    }
    .onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack;
    })
    .hideToolBar(true)
    .hideBackButton(true)
    .hideTitleBar(true)
  }
}
