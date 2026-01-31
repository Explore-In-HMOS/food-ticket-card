import {
  ArcButton,
  ArcButtonOptions,
  ArcButtonStyleMode,
  ColorMetrics,
  LengthMetrics,
  LengthUnit
} from '@kit.ArkUI';

@Builder
export function MainPageBuilder() {
  MainPage()
}

@Entry
@Component
struct MainPage {
  pageInfo: NavPathStack = new NavPathStack();
  scroller: Scroller = new Scroller();

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

          Text($r('app.string.my_card'))
            .fontSize(20 * this.calcScale(0))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.transaction_expense'))
            .textAlign(TextAlign.Center)
            .margin({ top: '10%', bottom: '6%' })
            .scale({ x: this.calcScale(0), y: this.calcScale(0) })

          Column() {
            Text('FOOD CARD')
              .fontSize(12 * this.calcScale(0))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.transaction_expense'))
              .margin({ top: '6%' })
              .scale({ x: this.calcScale(0), y: this.calcScale(0) })

            Text('••••  ••••  ••••  1234')
              .fontSize(14 * this.calcScale(0))
              .fontColor($r('app.color.transaction_expense'))
              .margin({ top: '4%' })
              .scale({ x: this.calcScale(0), y: this.calcScale(0) })

            Text('User Name')
              .fontSize(10 * this.calcScale(1))
              .fontColor($r('app.color.transaction_expense'))
              .margin({ top: '2%', bottom: '6%' })
              .scale({ x: this.calcScale(1), y: this.calcScale(1) })
          }
          .width('80%')
          .radialGradient({
            center: ['50%', '50%'],
            radius: '100%',
            repeating: false, // The gradients are not repeated.
            colors: [
              [$r('app.color.gradient_card_start'), 0.2],
              [$r('app.color.gradient_card_end'), 0.50],
              [0x000, 1.0]
            ]
          })
          .borderRadius(20)
          .padding({ bottom: '6%' })
          .alignSelf(ItemAlign.Center)

          Column() {
            Text('Balance')
              .fontSize(12 * this.calcScale(1))
              .fontColor($r('app.color.transaction_expense'))
              .margin({ top: '8%' })
              .scale({ x: this.calcScale(1), y: this.calcScale(1) })

            Text('₺ 152.75')
              .fontSize(26 * this.calcScale(0))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.transaction_expense'))
              .margin({ top: '2%', bottom: '8%' })
              .scale({ x: this.calcScale(0), y: this.calcScale(0) })
          }
          .alignSelf(ItemAlign.Center)

          ArcButton(
            {
              options: new ArcButtonOptions({
                label: 'Payment',
                styleMode: ArcButtonStyleMode.CUSTOM,
                fontSize: new LengthMetrics(14 * this.calcScale(1), LengthUnit.FP),
                fontColor: ColorMetrics.resourceColor($r('app.color.transaction_expense')),
                backgroundColor: ColorMetrics.resourceColor($r('app.color.input_border_focus')),
                onClick: () => {
                  this.pageInfo.pushPathByName('PaymentPageBuilder', null);
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

    }
    .onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack;
    })
    .hideToolBar(true)
    .hideBackButton(true)
    .hideTitleBar(true)
    .onBackPressed(() => {
      return false;
    })
  }
}
