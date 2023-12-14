module vvp::Vvp {
    use std::option;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};

    struct VVP has drop {}

    /// A shared counter.
    struct VVPCoin has key{
        id: UID,
        has_minted: u64,
    }

    fun init(witness: VVP, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<VVP>(witness, 9, b"Vvp", b"VVP", b"VVP", option::none(), ctx);
        let coin = VVPCoin {
            id: object::new(ctx),
            has_minted: 0,
        };

        transfer::share_object(coin);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
    }

    /// Manager can mint new coins
    public entry fun mint(
        treasury_cap: &mut TreasuryCap<VVP>, 
        coin: &mut VVPCoin,
        amount: u64, recipient: 
        address, 
        ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx);
        coin.has_minted = coin.has_minted + amount;
    }

    /// Manager can burn coins
    public entry fun burn(
        treasury_cap: &mut TreasuryCap<VVP>, 
        vvp_coin: &mut VVPCoin,
        coin: Coin<VVP>
    ) {
        vvp_coin.has_minted = vvp_coin.has_minted - coin::value(&coin);
        coin::burn(treasury_cap, coin);
    }

    /// transfer coins
    public entry fun transfer(c: &mut Coin<VVP>, value: u64, recipient: address, ctx: &mut TxContext) {
        transfer::public_transfer(
            coin::split(c, value, ctx), 
            recipient
        );
    }

    #[test_only]
    /// Wrapper of module initializer for testing
    public fun test_init(ctx: &mut TxContext) {
        init(VVP {}, ctx);
    }
}