import { cryptoFramework } from '@kit.CryptoArchitectureKit';

@Observed
export class PaymentViewModel {
  paymentCode: string = '--- ---';
  async generateCode() {
    try {
      const rand = cryptoFramework.createRandom();
      const randData = await rand.generateRandom(4);
      const dataView = new DataView(randData.data.buffer);
      const code = (100000 + (dataView.getUint32(0, true) % 900000)).toString();
      this.paymentCode = code.match(/.{1,3}/g)?.join(' ') ?? code;
      console.error(this.paymentCode);
    } catch (e) {
      console.error('Code generation failed');
    }
  }
}