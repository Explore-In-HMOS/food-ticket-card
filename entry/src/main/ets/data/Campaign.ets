export interface Campaign {
  id: number;
  title: string;
  description: string;
  restaurant: string;
  discountPercent: number;
}

export const MOCK_CAMPAIGNS: Campaign[] = [
  {
    id: 1,
    title: 'Delicious Burger Offer',
    description: 'Double-decker burger menu with 30% off! Only today.',
    restaurant: 'BurgerHub',
    discountPercent: 30
  },
  {
    id: 2,
    title: 'Hot Pide Campaign',
    description: '25% off on family-sized pide orders!',
    restaurant: 'Pideci Ali',
    discountPercent: 25
  },
  {
    id: 3,
    title: 'Sushi Delight',
    description: 'Buy 2 rolls, get 1 free. Until 10:00 PM.',
    restaurant: 'SushiGo',
    discountPercent: 33
  },
  {
    id: 4,
    title: 'Sweet Break',
    description: '20% off on cheesecake and coffee set!',
    restaurant: 'SweetTime',
    discountPercent: 20
  }
];