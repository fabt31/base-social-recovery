# base-social-recovery

> Social Recovery Wallet for Base L2

Never lose access to your crypto again. This social recovery wallet lets you recover your account using trusted guardians (friends, hardware wallets, or cold addresses) with a configurable M-of-N threshold.

## How It Works
1. 🔑 Deploy your wallet and set N guardians
2. 📲 Use normally with your daily key
3. 🚨 If key is lost, initiate recovery
4. ⏳ Guardians approve → 48h time-lock → new key set
5. ✅ Access restored, old key invalidated

## Features
- 👥 M-of-N guardian threshold
- ⏳ 48-hour recovery time-lock (cancellable)
- 🔒 Guardian privacy (hashed, not public)
- 📦 Batch transactions
- 🔄 Guardian rotation
- 🛡️ Replay attack protection

## Installation
```bash
git clone https://github.com/fabt31/base-social-recovery
forge install && forge build && forge test
```

## License
MIT