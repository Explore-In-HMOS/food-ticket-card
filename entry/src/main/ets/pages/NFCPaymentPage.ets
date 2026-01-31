import {
  ArcButton,
  ArcButtonOptions,
  ArcButtonStyleMode,
  ColorMetrics,
  LengthMetrics,
  LengthUnit,
  promptAction
} from '@kit.ArkUI';
import { tag } from '@kit.ConnectivityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import vibrator from '@ohos.vibrator';

type VibrateUsage = 'unknown' | 'notification' | 'ring' | 'alarm';

interface VibrateAttribute { usage: VibrateUsage }

interface TimeVibrateEffect {
  type: 'time';
  duration: number
}

@Builder
export function NfcPayPageBuilder(): void {
  NfcPayPage();
}

interface GeneratedObjectLiteralInterface {
  bundleName: string;
  abilityName: string;
  moduleName: string;
}

@Component
struct NfcPayPage {
  pageInfo: NavPathStack = new NavPathStack();
  private isScanning: boolean = true;
  private scanMessage: string = 'Bring your device close to the POS terminal';
  private progressValue: number = 0;
  private pulseScale: number = 1.0;
  private ringOpacity: number = 0.4;
  private timerId: number | undefined = undefined;
  private pulseTimerId: number | undefined = undefined;
  private isNfcRegistered: boolean = false;
  private hasNavigated: boolean = false;
  private readonly nfcTagElementName: GeneratedObjectLiteralInterface = {
    bundleName: 'com.hmosdemos.wearable.food_ticket_card',
    abilityName: 'EntryAbility',
    moduleName: 'ability'
  };

  private readonly techList: number[] = [tag.NFC_A, tag.NFC_B, tag.NFC_F, tag.NFC_V];

  calcScale(position: number): number {
    if (position === 0) {
      return 1.0;
    }
    if (position === 1) {
      return 0.85;
    }
    return 0.70;
  }

  async vibrate(ms: number): Promise<void> {
    try {
      await vibrator.startVibration({ type: 'time', duration: ms } as TimeVibrateEffect,
        { usage: 'unknown' } as VibrateAttribute);
    } catch (e) {
      console.error('vibration error', JSON.stringify(e));
    }
  }

  aboutToAppear(): void {
    this.hasNavigated = false;
    this.startScanning();
    this.startPulseAnimation();
    this.startNfc();
  }

  aboutToDisappear(): void {
    this.stopScanning();
    this.stopPulseAnimation();
    this.stopNfc();
  }

  private startScanning(): void {
    this.stopScanning();
    this.progressValue = 0;
    this.isScanning = true;
    this.scanMessage = 'Bring your device close to the POS terminal';

    this.timerId = setInterval(() => {
      this.progressValue = Math.min(100, this.progressValue + 1);

      if (this.progressValue >= 100) {
        this.scanMessage = 'Payment Successful';
        this.isScanning = false;
        this.stopScanning();
        this.vibrate(150);
        this.goBack();
      }
    }, 300) as number;
  }

  private startPulseAnimation(): void {
    this.stopPulseAnimation();
    this.pulseTimerId = setInterval(() => {
      this.pulseScale = this.pulseScale === 1.0 ? 1.15 : 1.0;
    }, 1000) as number;
  }

  private stopPulseAnimation(): void {
    if (this.pulseTimerId !== undefined) {
      clearInterval(this.pulseTimerId);
      this.pulseTimerId = undefined;
      this.pulseScale = 1.0;
    }
  }

  private stopScanning(): void {
    if (this.timerId !== undefined) {
      clearInterval(this.timerId);
      this.timerId = undefined;
    }
    this.isScanning = false;
  }

  private goBack(): void {
    this.pageInfo.pop();
  }

  private startNfc(): void {
    try {
      if (typeof canIUse === 'function' && !canIUse('SystemCapability.Communication.NFC.Core')) {
        hilog.error(0x0000, 'NfcPayPage', 'NFC not available on device.');
        return;
      }
      if (!this.isNfcRegistered) {
        tag.on('readerMode', this.nfcTagElementName, this.techList, this.readerModeCb);
        this.isNfcRegistered = true;
        hilog.info(0x0000, 'NfcPayPage', 'NFC readerMode registered (aboutToAppear)');
      }
    } catch (err) {
      hilog.error(0x0000, 'NfcPayPage', `tag.on error = %{public}s`, JSON.stringify(err));
    }
  }

  private stopNfc(): void {
    if (this.isNfcRegistered) {
      try {
        tag.off('readerMode', this.nfcTagElementName);
        hilog.info(0x0000, 'NfcPayPage', 'NFC readerMode unregistered (aboutToDisappear)');
      } catch (err) {
        hilog.error(0x0000, 'NfcPayPage', `tag.off error = %{public}s`, JSON.stringify(err));
      } finally {
        this.isNfcRegistered = false;
      }
    }
  }

  private stringToBytes(input: string): number[] {
    const bytes: number[] = [];
    for (let i: number = 0; i < input.length; i++) {
      bytes.push(input.charCodeAt(i) & 0xFF);
    }
    return bytes;
  }

  private readerModeCb = (error: BusinessError, tagInfo: tag.TagInfo) => {
    if (!error) {
      if (!tagInfo) {
        hilog.error(0x0000, 'NfcPayPage', 'readerModeCb: invalid tagInfo');
        return;
      }
      if (!tagInfo.uid || !tagInfo.technology) {
        hilog.error(0x0000, 'NfcPayPage', 'readerModeCb: invalid tagInfo.uid');
        return;
      }
      if (tagInfo.technology.length === 0) {
        hilog.error(0x0000, 'NfcPayPage', 'readerModeCb: tagInfo technology length is zero');
        return;
      }
      let isoDep: tag.IsoDepTag | null = null;
      const tagSize: number = tagInfo.technology.length;
      for (let i = 0; i < tagSize; i++) {
        if (tagInfo.technology[i] === tag.ISO_DEP) {
          try {
            isoDep = tag.getIsoDep(tagInfo);
          } catch (err) {
            hilog.error(0x0000, 'NfcPayPage', `getIsoDep error = %{public}s`, JSON.stringify(err));
            return;
          }
        }
      }
      if (!isoDep) {
        hilog.error(0x0000, 'NfcPayPage', 'readerModeCb getIsoDep is invalid');
        return;
      }
      try {
        isoDep.connect();
      } catch (err) {
        hilog.error(0x0000, 'NfcPayPage', `isoDep.connect() error = %{public}s`, JSON.stringify(err));
        return;
      }
      if (!isoDep.isConnected()) {
        hilog.error(0x0000, 'NfcPayPage', 'isoDep.isConnected() false.');
        return;
      }
      const payloadToSend: string = 'PAYLOAD|orderId=12345|amount=100';
      const payload: number[] = this.stringToBytes(payloadToSend);
      const MAX_SINGLE: number = 255;
      const apdu: number[] = [];

      if (payload.length <= MAX_SINGLE) {
        apdu.push(0x00);
        apdu.push(0xDA);
        apdu.push(0x00);
        apdu.push(0x00);
        apdu.push(payload.length);
        apdu.push(...payload);
      }
      const cmdData = apdu; // modify per your protoco
      try {
        isoDep.transmit(cmdData).then((response: number[]) => {
          hilog.info(0x0000, 'NfcPayPage', 'isoDep.transmit() response = %{public}s.', JSON.stringify(response));
          const success = true;
          if (success) {
            this.scanMessage = 'Payment Successful';
            this.isScanning = false;
            this.stopScanning();
            if (!this.hasNavigated) {
              this.hasNavigated = true;
              this.stopNfc();
              try {
                try {
                  this.getUIContext().getPromptAction().showToast({
                    message: 'Payment Done',
                    duration: 2000,
                    showMode: promptAction.ToastShowMode.DEFAULT,
                    bottom: 80
                  });
                } catch (error) {

                }
                this.vibrate(150);
                this.goBack();
              } catch (navErr) {
                hilog.error(0x0000, 'NfcPayPage', `Navigation error = %{public}s`, JSON.stringify(navErr));
              }
            }
          } else {
            hilog.info(0x0000, 'NfcPayPage', 'isoDep.transmit() returned non-success response.');
          }
        }).catch((tErr: BusinessError) => {
          hilog.error(0x0000, 'NfcPayPage', 'isoDep.transmit() err = %{public}s.', JSON.stringify(tErr));
        });
      } catch (bErr) {
        hilog.error(0x0000, 'NfcPayPage', 'isoDep.transmit() businessError = %{public}s.', JSON.stringify(bErr));
      }
    } else {
      hilog.error(0x0000, 'NfcPayPage', 'readerModeCb error %{public}s', JSON.stringify(error));
    }
  };

  build() {
    NavDestination() {
      Column() {
        Text('PlusPay NFC')
          .fontSize(20 * this.calcScale(0))
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
          .margin({ top: '12%', bottom: '5%' })
          .scale({ x: this.calcScale(0), y: this.calcScale(0) })

        Stack() {
          Image($r('app.media.nfc_icon'))
            .width('35%')
            .aspectRatio(1)
            .scale({ x: this.pulseScale, y: this.pulseScale })
            .animation({ duration: 900, curve: Curve.EaseInOut })
        }
        .padding(10)
        .borderRadius(16)

        Progress({ value: this.progressValue, total: 100, type: ProgressType.Linear })
          .width('70%')
          .height(10)
          .alignSelf(ItemAlign.Center)
          .color($r('app.color.input_border_focus'))
          .backgroundColor('#333A55')
          .animation({ duration: 300, curve: Curve.EaseInOut })
          .margin({ bottom: '8%' })

        ArcButton({
          options: new ArcButtonOptions({
            label: 'Back',
            styleMode: ArcButtonStyleMode.CUSTOM,
            fontSize: new LengthMetrics(14 * this.calcScale(1), LengthUnit.FP),
            fontColor: ColorMetrics.resourceColor($r('app.color.transaction_expense')),
            backgroundColor: ColorMetrics.resourceColor($r('app.color.input_border_focus')),
            onClick: () => this.goBack()
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
    .onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack;
    })
    .hideToolBar(true)
    .hideBackButton(true)
    .hideTitleBar(true)
  }
}