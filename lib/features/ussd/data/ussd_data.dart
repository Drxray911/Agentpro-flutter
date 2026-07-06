import 'package:collection/collection.dart';
import 'ussd_models.dart';

/// Static USSD menu tree data, ported from the prototype's USSD_TREES.
/// In production this could be fetched from the Provider Management API
/// (spec §5 — /providers) so Superusers can edit menus without an app update,
/// but a bundled fallback (this file) ensures the navigator works offline.
class UssdData {
  UssdData._();

  static final mtn = UssdProvider(
    id: 'MTN',
    code: '*170#',
    name: 'MTN MoMo',
    colorValue: 0xFFFFCC00,
    icon: '🟡',
    root: UssdNode(
      title: 'Welcome to MTN MoMo\nEnter your PIN to continue',
      requiresPin: true,
      next: UssdNode(
        title: 'MTN Mobile Money\n1. Send Money\n2. Cash Out\n3. Cash In\n4. Pay Bill\n'
            '5. Buy Airtime\n6. Buy Bundle\n7. Check Balance\n8. My Wallet\n0. Back',
        options: {
          '1': UssdOption.node(UssdNode(
            title: 'Send Money\n1. To MTN Number\n2. To Other Network\n3. To Bank Account\n0. Back',
            options: {
              '1': UssdOption.node(UssdNode(
                title: 'Send to MTN\nEnter recipient number:',
                inputType: UssdInputType.phone,
                next: UssdNode(
                  title: 'Enter amount (GH₵):',
                  inputType: UssdInputType.amount,
                  next: UssdNode(title: 'Enter your PIN:', inputType: UssdInputType.pin, terminal: 'send_mtn'),
                ),
              )),
              '2': UssdOption.node(UssdNode(
                title: 'Other Network\nEnter number:',
                inputType: UssdInputType.phone,
                next: UssdNode(
                  title: 'Enter amount (GH₵):',
                  inputType: UssdInputType.amount,
                  next: UssdNode(title: 'Enter your PIN:', inputType: UssdInputType.pin, terminal: 'send_other'),
                ),
              )),
              '3': UssdOption.node(UssdNode(
                title: 'Bank Account\nEnter account number:',
                inputType: UssdInputType.text,
                next: UssdNode(
                  title: 'Enter amount (GH₵):',
                  inputType: UssdInputType.amount,
                  next: UssdNode(title: 'Enter your PIN:', inputType: UssdInputType.pin, terminal: 'send_bank'),
                ),
              )),
              '0': UssdOption.back(),
            },
          )),
          '2': UssdOption.node(UssdNode(
            title: 'Cash Out\nEnter Agent Code:',
            inputType: UssdInputType.text,
            next: UssdNode(
              title: 'Enter amount (GH₵):',
              inputType: UssdInputType.amount,
              next: UssdNode(title: 'Enter your PIN:', inputType: UssdInputType.pin, terminal: 'cashout'),
            ),
          )),
          '3': UssdOption.node(UssdNode(
            title: 'Cash In\n1. Self\n2. For Someone Else\n0. Back',
            options: {
              '1': UssdOption.node(UssdNode(
                title: 'Enter amount (GH₵):',
                inputType: UssdInputType.amount,
                next: UssdNode(
                  title: 'Enter Agent Code:',
                  inputType: UssdInputType.text,
                  next: UssdNode(title: 'Enter your PIN:', inputType: UssdInputType.pin, terminal: 'cashin_self'),
                ),
              )),
              '2': UssdOption.node(UssdNode(
                title: 'Enter recipient number:',
                inputType: UssdInputType.phone,
                next: UssdNode(
                  title: 'Enter amount (GH₵):',
                  inputType: UssdInputType.amount,
                  next: UssdNode(title: 'Enter your PIN:', inputType: UssdInputType.pin, terminal: 'cashin_other'),
                ),
              )),
              '0': UssdOption.back(),
            },
          )),
          '4': UssdOption.node(UssdNode(
            title: 'Pay Bill\n1. Electricity (ECG)\n2. Water (GWCL)\n3. DStv\n0. Back',
            options: {
              '1': UssdOption.node(UssdNode(
                title: 'ECG Prepaid\nEnter meter number:',
                inputType: UssdInputType.text,
                next: UssdNode(
                  title: 'Enter amount (GH₵):',
                  inputType: UssdInputType.amount,
                  next: UssdNode(title: 'Enter your PIN:', inputType: UssdInputType.pin, terminal: 'bill_ecg'),
                ),
              )),
              '2': UssdOption.node(UssdNode(
                title: 'GWCL Water\nEnter account number:',
                inputType: UssdInputType.text,
                next: UssdNode(
                  title: 'Enter amount (GH₵):',
                  inputType: UssdInputType.amount,
                  next: UssdNode(title: 'Enter your PIN:', inputType: UssdInputType.pin, terminal: 'bill_water'),
                ),
              )),
              '3': UssdOption.node(UssdNode(
                title: 'DStv\nEnter smartcard number:',
                inputType: UssdInputType.text,
                next: UssdNode(
                  title: 'Select package:\n1. Compact GH₵55\n2. Compact+ GH₵95\n3. Premium GH₵215\n0. Back',
                  options: {
                    '1': UssdOption.node(UssdNode(title: 'Enter your PIN:', inputType: UssdInputType.pin, terminal: 'bill_dstv_compact')),
                    '2': UssdOption.node(UssdNode(title: 'Enter your PIN:', inputType: UssdInputType.pin, terminal: 'bill_dstv_plus')),
                    '3': UssdOption.node(UssdNode(title: 'Enter your PIN:', inputType: UssdInputType.pin, terminal: 'bill_dstv_premium')),
                    '0': UssdOption.back(),
                  },
                ),
              )),
              '0': UssdOption.back(),
            },
          )),
          '5': UssdOption.node(UssdNode(
            title: 'Buy Airtime\n1. For Myself\n2. For Others\n0. Back',
            options: {
              '1': UssdOption.node(UssdNode(
                title: 'Enter amount (GH₵):',
                inputType: UssdInputType.amount,
                next: UssdNode(title: 'Enter your PIN:', inputType: UssdInputType.pin, terminal: 'airtime_self'),
              )),
              '2': UssdOption.node(UssdNode(
                title: 'Enter number:',
                inputType: UssdInputType.phone,
                next: UssdNode(
                  title: 'Enter amount (GH₵):',
                  inputType: UssdInputType.amount,
                  next: UssdNode(title: 'Enter your PIN:', inputType: UssdInputType.pin, terminal: 'airtime_other'),
                ),
              )),
              '0': UssdOption.back(),
            },
          )),
          '6': UssdOption.node(UssdNode(
            title: 'Buy Bundle\n1. 500MB - GH₵5\n2. 1GB - GH₵9\n3. 3GB - GH₵22\n0. Back',
            options: {
              '1': UssdOption.node(UssdNode(title: 'Enter your PIN:', inputType: UssdInputType.pin, terminal: 'bundle_500mb')),
              '2': UssdOption.node(UssdNode(title: 'Enter your PIN:', inputType: UssdInputType.pin, terminal: 'bundle_1gb')),
              '3': UssdOption.node(UssdNode(title: 'Enter your PIN:', inputType: UssdInputType.pin, terminal: 'bundle_3gb')),
              '0': UssdOption.back(),
            },
          )),
          '7': UssdOption.node(UssdNode(title: 'Checking balance...\nPlease wait.', terminal: 'balance')),
          '8': UssdOption.node(UssdNode(
            title: 'My Wallet\n1. Mini Statement\n2. Change PIN\n0. Back',
            options: {
              '1': UssdOption.node(UssdNode(title: 'Fetching statement...', terminal: 'mini_statement')),
              '2': UssdOption.node(UssdNode(
                title: 'Enter current PIN:',
                inputType: UssdInputType.pin,
                next: UssdNode(
                  title: 'Enter new PIN:',
                  inputType: UssdInputType.pin,
                  next: UssdNode(title: 'Confirm new PIN:', inputType: UssdInputType.pin, terminal: 'change_pin'),
                ),
              )),
              '0': UssdOption.back(),
            },
          )),
          '0': UssdOption.back(),
        },
      ),
    ),
  );

  static final telecel = UssdProvider(
    id: 'Telecel',
    code: '*110#',
    name: 'Telecel Cash',
    colorValue: 0xFFDC143C,
    icon: '🔴',
    root: UssdNode(
      title: 'Welcome to Telecel Cash\nEnter PIN to continue',
      requiresPin: true,
      next: UssdNode(
        title: 'Telecel Cash Menu\n1. Send Money\n2. Withdraw Cash\n3. Deposit Cash\n'
            '4. Pay for Goods\n5. Buy Airtime\n6. Check Balance\n0. Exit',
        options: {
          '1': UssdOption.node(UssdNode(
            title: 'Send Money\n1. Telecel Number\n2. Other Network\n0. Back',
            options: {
              '1': UssdOption.node(UssdNode(
                title: 'Recipient number:',
                inputType: UssdInputType.phone,
                next: UssdNode(
                  title: 'Amount (GH₵):',
                  inputType: UssdInputType.amount,
                  next: UssdNode(title: 'PIN:', inputType: UssdInputType.pin, terminal: 'send_telecel'),
                ),
              )),
              '2': UssdOption.node(UssdNode(
                title: 'Recipient number:',
                inputType: UssdInputType.phone,
                next: UssdNode(
                  title: 'Amount (GH₵):',
                  inputType: UssdInputType.amount,
                  next: UssdNode(title: 'PIN:', inputType: UssdInputType.pin, terminal: 'send_other'),
                ),
              )),
              '0': UssdOption.back(),
            },
          )),
          '2': UssdOption.node(UssdNode(
            title: 'Agent number:',
            inputType: UssdInputType.text,
            next: UssdNode(
              title: 'Amount (GH₵):',
              inputType: UssdInputType.amount,
              next: UssdNode(title: 'PIN:', inputType: UssdInputType.pin, terminal: 'cashout'),
            ),
          )),
          '3': UssdOption.node(UssdNode(
            title: 'Amount (GH₵):',
            inputType: UssdInputType.amount,
            next: UssdNode(
              title: 'Agent code:',
              inputType: UssdInputType.text,
              next: UssdNode(title: 'PIN:', inputType: UssdInputType.pin, terminal: 'cashin'),
            ),
          )),
          '4': UssdOption.node(UssdNode(
            title: 'Merchant number:',
            inputType: UssdInputType.text,
            next: UssdNode(
              title: 'Amount (GH₵):',
              inputType: UssdInputType.amount,
              next: UssdNode(title: 'PIN:', inputType: UssdInputType.pin, terminal: 'merchant'),
            ),
          )),
          '5': UssdOption.node(UssdNode(
            title: 'Amount (GH₵):',
            inputType: UssdInputType.amount,
            next: UssdNode(title: 'PIN:', inputType: UssdInputType.pin, terminal: 'airtime'),
          )),
          '6': UssdOption.node(UssdNode(title: 'Fetching balance...', terminal: 'balance')),
          '0': UssdOption.back(),
        },
      ),
    ),
  );

  static final at = UssdProvider(
    id: 'AT',
    code: '*500#',
    name: 'AT Money',
    colorValue: 0xFF0047AB,
    icon: '🔵',
    root: UssdNode(
      title: 'Welcome to AT Money\nEnter your PIN:',
      requiresPin: true,
      next: UssdNode(
        title: 'AT Money Services\n1. Send Money\n2. Withdraw\n3. Deposit\n'
            '4. Pay Bills\n5. Airtime & Bundles\n6. Balance\n0. Exit',
        options: {
          '1': UssdOption.node(UssdNode(
            title: 'Recipient number:',
            inputType: UssdInputType.phone,
            next: UssdNode(
              title: 'Amount (GH₵):',
              inputType: UssdInputType.amount,
              next: UssdNode(title: 'PIN:', inputType: UssdInputType.pin, terminal: 'send'),
            ),
          )),
          '2': UssdOption.node(UssdNode(
            title: 'Agent ID:',
            inputType: UssdInputType.text,
            next: UssdNode(
              title: 'Amount (GH₵):',
              inputType: UssdInputType.amount,
              next: UssdNode(title: 'PIN:', inputType: UssdInputType.pin, terminal: 'cashout'),
            ),
          )),
          '3': UssdOption.node(UssdNode(
            title: 'Amount (GH₵):',
            inputType: UssdInputType.amount,
            next: UssdNode(
              title: 'Agent ID:',
              inputType: UssdInputType.text,
              next: UssdNode(title: 'PIN:', inputType: UssdInputType.pin, terminal: 'cashin'),
            ),
          )),
          '4': UssdOption.node(UssdNode(
            title: 'Bills\n1. ECG Prepaid\n2. ECG Postpaid\n0. Back',
            options: {
              '1': UssdOption.node(UssdNode(
                title: 'Meter number:',
                inputType: UssdInputType.text,
                next: UssdNode(
                  title: 'Amount (GH₵):',
                  inputType: UssdInputType.amount,
                  next: UssdNode(title: 'PIN:', inputType: UssdInputType.pin, terminal: 'bill_ecg'),
                ),
              )),
              '2': UssdOption.node(UssdNode(
                title: 'Account number:',
                inputType: UssdInputType.text,
                next: UssdNode(
                  title: 'Amount (GH₵):',
                  inputType: UssdInputType.amount,
                  next: UssdNode(title: 'PIN:', inputType: UssdInputType.pin, terminal: 'bill_ecg_post'),
                ),
              )),
              '0': UssdOption.back(),
            },
          )),
          '5': UssdOption.node(UssdNode(
            title: 'Airtime & Bundles\n1. Buy Airtime\n2. Buy Bundle\n0. Back',
            options: {
              '1': UssdOption.node(UssdNode(
                title: 'Amount (GH₵):',
                inputType: UssdInputType.amount,
                next: UssdNode(title: 'PIN:', inputType: UssdInputType.pin, terminal: 'airtime'),
              )),
              '2': UssdOption.node(UssdNode(
                title: 'Select bundle:\n1. 1GB - GH₵9\n2. 3GB - GH₵22\n0. Back',
                options: {
                  '1': UssdOption.node(UssdNode(title: 'PIN:', inputType: UssdInputType.pin, terminal: 'bundle_1gb')),
                  '2': UssdOption.node(UssdNode(title: 'PIN:', inputType: UssdInputType.pin, terminal: 'bundle_3gb')),
                  '0': UssdOption.back(),
                },
              )),
              '0': UssdOption.back(),
            },
          )),
          '6': UssdOption.node(UssdNode(title: 'Fetching balance...', terminal: 'balance')),
          '0': UssdOption.back(),
        },
      ),
    ),
  );

  static final List<UssdProvider> providers = [mtn, telecel, at];

  static UssdProvider? byId(String id) => providers.where((p) => p.id == id).firstOrNull;

  /// Terminal leaf responses keyed by the `terminal` string set on a [UssdNode].
  /// Ported verbatim from the prototype's TERMINAL_RESPONSES.
  static final Map<String, UssdResponse> responses = {
    'balance': const UssdResponse(success: true, messageTemplate: 'Account Balance\n\nAvailable: GH₵ 1,620.00\nActual: GH₵ 1,620.00\n\nDate: {date}'),
    'send_mtn': const UssdResponse(success: true, messageTemplate: 'Transfer Successful!\n\nGH₵ {amount} sent\nRef: {ref}\n\nNew Balance: GH₵ 1,320.00'),
    'send_telecel': const UssdResponse(success: true, messageTemplate: 'Transfer Successful!\n\nGH₵ {amount} sent\nRef: {ref}'),
    'send_other': const UssdResponse(success: true, messageTemplate: 'Transfer Successful!\n\nGH₵ {amount} sent\nRef: {ref}'),
    'send_bank': const UssdResponse(success: true, messageTemplate: 'Bank Transfer Initiated\n\nGH₵ {amount}\nProcessing: 1-2 business days\nRef: {ref}'),
    'send': const UssdResponse(success: true, messageTemplate: 'Transfer Successful!\n\nGH₵ {amount} sent\nRef: {ref}'),
    'cashout': const UssdResponse(success: true, messageTemplate: 'Cash Out Approved!\n\nAgent will pay: GH₵ {amount}\nRef: {ref}\n\nShow this code to agent:\n{token}'),
    'cashin': const UssdResponse(success: true, messageTemplate: 'Cash In Successful!\n\nGH₵ {amount} received\nRef: {ref}\n\nNew Balance: GH₵ 1,920.00'),
    'cashin_self': const UssdResponse(success: true, messageTemplate: 'Cash In Successful!\n\nGH₵ {amount} received\nRef: {ref}'),
    'cashin_other': const UssdResponse(success: true, messageTemplate: 'Cash In Successful!\n\nRecipient received: GH₵ {amount}\nRef: {ref}'),
    'merchant': const UssdResponse(success: true, messageTemplate: 'Payment Successful!\n\nGH₵ {amount} paid\nMerchant confirmed\nRef: {ref}'),
    'bill_ecg': const UssdResponse(success: true, messageTemplate: 'ECG Prepaid Purchased!\n\nAmount: GH₵ {amount}\nToken: 4521-9834-2211-0045\nRef: {ref}'),
    'bill_ecg_post': const UssdResponse(success: true, messageTemplate: 'ECG Postpaid Paid!\n\nAmount: GH₵ {amount}\nAccount updated\nRef: {ref}'),
    'bill_water': const UssdResponse(success: true, messageTemplate: 'Water Bill Paid!\n\nAmount: GH₵ {amount}\nRef: {ref}'),
    'bill_dstv_compact': const UssdResponse(success: true, messageTemplate: 'DStv Compact Renewed!\n\nGH₵ 55.00 paid\nValid: 30 days\nRef: {ref}'),
    'bill_dstv_plus': const UssdResponse(success: true, messageTemplate: 'DStv Compact+ Renewed!\n\nGH₵ 95.00 paid\nValid: 30 days\nRef: {ref}'),
    'bill_dstv_premium': const UssdResponse(success: true, messageTemplate: 'DStv Premium Renewed!\n\nGH₵ 215.00 paid\nValid: 30 days\nRef: {ref}'),
    'airtime': const UssdResponse(success: true, messageTemplate: 'Airtime Purchased!\n\nGH₵ {amount} airtime\nAdded to your line\nRef: {ref}'),
    'airtime_self': const UssdResponse(success: true, messageTemplate: 'Airtime Purchased!\n\nGH₵ {amount} added\nRef: {ref}'),
    'airtime_other': const UssdResponse(success: true, messageTemplate: 'Airtime Sent!\n\nGH₵ {amount} sent\nRef: {ref}'),
    'bundle_500mb': const UssdResponse(success: true, messageTemplate: 'Bundle Activated!\n\n500MB Data Bundle\nCost: GH₵ 5.00\nValid: 24 hours\nRef: {ref}'),
    'bundle_1gb': const UssdResponse(success: true, messageTemplate: 'Bundle Activated!\n\n1GB Data Bundle\nCost: GH₵ 9.00\nValid: 7 days\nRef: {ref}'),
    'bundle_3gb': const UssdResponse(success: true, messageTemplate: 'Bundle Activated!\n\n3GB Data Bundle\nCost: GH₵ 22.00\nValid: 30 days\nRef: {ref}'),
    'change_pin': const UssdResponse(success: true, messageTemplate: 'PIN Changed Successfully!\n\nYour new PIN is active.\nKeep it safe and private.'),
    'mini_statement': const UssdResponse(success: true, messageTemplate: 'Mini Statement\n\n1. Cash In +500.00\n2. Airtime -9.00\n3. Send -300.00\n\nBalance: GH₵ 1,620.00'),
  };
}
