module solve::m {
    use game::hero::{Self, Hero};
    use game::adventure;
    use game::inventory::{Self, TreasuryBox};

    use solve::hack_random;
    use sui::tx_context::{TxContext};

    public entry fun kill(hero: &mut Hero, ctx: &mut TxContext) {
        let i = 0;
        while (i < 200) {
            adventure::slay_boar(hero, ctx);
            if (hero::experience(hero) >= 100 ) {
                break
            };
            i = i + 1;
        };
        hero::level_up(hero);

        hack_random::refresh_ctx(4, ctx);
        adventure::slay_boar_king(hero, ctx);
    }

    public entry fun get_flag(box: TreasuryBox, ctx: &mut TxContext) {
        hack_random::refresh_ctx(0, ctx);
        inventory::get_flag(box, ctx);
    }
}