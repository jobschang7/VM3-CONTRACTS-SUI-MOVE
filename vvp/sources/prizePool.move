module vvp::PrizePool {
    use sui::signer::Signer;
    use vvp::Vvp;
    use sui::map::Map;
    use sui::timestamp::Timestamp;

    struct Prize {
        amount: u64,
        expiry: u64,
    }

    struct PrizePool {
        prizes: Map<address, Vector<Prize>>,
    }

    public fun initialize(admin: &signer) {
        move_to(admin, PrizePool { prizes: Map::empty() });
    }

    public fun deposit(admin: &signer, recipient: address, amount: u64, expiry: u64) acquires PrizePool {
        let pool = borrow_global_mut<PrizePool>(Signer::address_of(admin));
        let prize_list = Map::get_mut_with_default(&mut pool.prizes, recipient, Vector::empty());
        Vector::push_back(prize_list, Prize { amount, expiry });
    }

    public fun claim_all_prizes(user: &signer) acquires PrizePool {
        let current_timestamp = Timestamp::now();
        let pool = borrow_global_mut<PrizePool>(Signer::address_of(user));
        let mut total_amount = 0u64;

        if (Map::contains_key(&pool.prizes, Signer::address_of(user))) {
            let prizes = Map::remove(&mut pool.prizes, Signer::address_of(user));
            
            for prize in &prizes {
                if (current_timestamp < prize.expiry) {
                    total_amount = total_amount + prize.amount;
                }
            }
        }

        Vvp::transfer_from_pool_to_user(total_amount, user);
    }

}