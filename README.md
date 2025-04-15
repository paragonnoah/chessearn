# ChessEarn
A global chess platform with 1v1 gameplay, future gambling, team play, tournaments, rooms, and payments (M-Pesa, Stripe, PayPal, Bitcoin).

## Week 1
- **Flutter**: Local chessboard (hotseat mode).
- **Flask**: Deployed to AWS EC2 with Cloudflare (`https://api.chessearn.com`).
- **React**: Empty admin panel scaffold.
- **Payments**: Stripe/M-Pesa sandboxes registered.

## Setup
1. **Flutter**: Install [Flutter SDK](https://flutter.dev), run `flutter doctor`.
2. **Flask**: Install Python 3.9+, `pip install -r backend/requirements.txt`.
3. **React**: Install Node.js 18+, run `npm install` in `admin/`.
4. **AWS**: Deploy `backend/` to EC2, use Cloudflare for SSL.
5. **Run**:
   - Flutter: `cd mobile && flutter run`
   - Flask: `cd backend && python app/main.py`
   - React: `cd admin && npm start`

## Global Notes
- Targets Android (2.5B devices) for Africa, Asia.
- AWS + Cloudflare ensures <300ms latency (US, Kenya).
- Multi-language UI planned for Week 2 (English, Spanish, French).