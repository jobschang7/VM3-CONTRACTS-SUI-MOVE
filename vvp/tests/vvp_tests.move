// Copyright (c) VMeta3 Labs, Inc.
// SPDX-License-Identifier: MIT

#[test_only]
module vvp::Vvp_tests {
    use vvp::Vvp::{Self, VVP, VVPCoin};
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::test_scenario::{Self, next_tx, ctx};

    #[test]
    fun mint_and_burn() {
        // Initialize a mock sender address
        let addr1 = @0xA;

        // Begins a multi transaction scenario with addr1 as the sender
        let scenario = test_scenario::begin(addr1);
        
        // Run the vvp coin module init function
        {
            vvp::test_init(ctx(&mut scenario));
        };

        // Mint a `Coin<VVP>` object
        next_tx(&mut scenario, addr1);
        {
            let treasurycap = test_scenario::take_from_sender<TreasuryCap<VVP>>(&scenario);
            let vvp_coin = test_scenario::take_shared<VVPCoin>(&scenario);
            vvp::mint(&mut treasurycap, &mut vvp_coin, 100, addr1, test_scenario::ctx(&mut scenario));
            
            test_scenario::return_shared<VVPCoin>(vvp_coin);
            test_scenario::return_to_address<TreasuryCap<VVP>>(addr1, treasurycap);
        };

        // Burn a `Coin<VVP>` object
        next_tx(&mut scenario, addr1);
        {
            let coin = test_scenario::take_from_sender<Coin<VVP>>(&scenario);
            let vvp_coin = test_scenario::take_shared<VVPCoin>(&scenario);

            assert!(coin::value(&coin) == 100, 0);
            let treasurycap = test_scenario::take_from_sender<TreasuryCap<VVP>>(&scenario);
            vvp::burn(&mut treasurycap, &mut vvp_coin, coin);

            test_scenario::return_shared<VVPCoin>(vvp_coin);
            test_scenario::return_to_address<TreasuryCap<VVP>>(addr1, treasurycap);
        };

        // Cleans up the scenario object
        test_scenario::end(scenario);
    }

}
