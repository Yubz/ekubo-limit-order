use ekubo::interfaces::core::{ICoreDispatcher, ICoreDispatcherTrait};
use ekubo::interfaces::positions::{IPositionsDispatcher, IPositionsDispatcherTrait};
use ekubo::types::keys::{PoolKey, PositionKey};
use ekubo::types::i129::{i129};
use core::traits::{TryInto, Into};
use core::option::{OptionTrait};
use starknet::ContractAddress;

#[derive(Copy, Drop, starknet::Store)]
struct LimitOrderInfo {
    position_id: u64,
    owner: ContractAddress,
    tick: i129
}

#[starknet::interface]
pub trait ILimitOrder<TStorage> {
    // Set a limit order at a given tick 
    fn set_limit_order(self: @TStorage, pool_key: PoolKey, tick: i129, amount: u128);
}

#[starknet::contract]
mod LimitOrder {
    use super::{ILimitOrder, PoolKey, PositionKey, LimitOrderInfo, i129};
    use ekubo::types::call_points::{CallPoints};
    use ekubo::types::delta::{Delta};
    use ekubo::interfaces::core::{ICoreDispatcher, ICoreDispatcherTrait, IExtension, SwapParameters, UpdatePositionParameters};
    use ekubo::interfaces::positions::{IPositionsDispatcher, IPositionsDispatcherTrait};
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address};
    use alexandria_storage::list::List;

    #[storage]
    struct Storage {
        core: ICoreDispatcher,
        positions: IPositionsDispatcher,
        limit_orders: LegacyMap<PoolKey, List<LimitOrderInfo>>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, core: ICoreDispatcher, positions: IPositionsDispatcher) {
        self.core.write(core);
        self.positions.write(positions);
    }

    #[generate_trait]
    impl Internal of InternalTrait {
        fn check_caller_is_core(self: @ContractState) -> ICoreDispatcher {
            let core = self.core.read();
            assert(core.contract_address == get_caller_address(), 'CALLER_NOT_CORE');
            core
        }
    }

    #[abi(embed_v0)]
    impl EkuboLimitOrderImpl of ILimitOrder<ContractState> {
        fn set_limit_order(self: @ContractState, pool_key: PoolKey, tick: i129, amount: u128) {
        }
    }

    #[abi(embed_v0)]
    impl EkuboLimitOrderExtension of IExtension<ContractState> {
        fn before_initialize_pool(
            ref self: ContractState, caller: ContractAddress, pool_key: PoolKey, initial_tick: i129
        ) -> CallPoints {
            self.check_caller_is_core();

            CallPoints {
                after_initialize_pool: false,
                before_swap: false,
                after_swap: false,
                before_update_position: false,
                after_update_position: false,
            }
        }

        fn after_initialize_pool(
            ref self: ContractState, caller: ContractAddress, pool_key: PoolKey, initial_tick: i129
        ) {
            assert(false, 'NOT_USED');
        }

        fn before_swap(
            ref self: ContractState,
            caller: ContractAddress,
            pool_key: PoolKey,
            params: SwapParameters
        ) {
            assert(false, 'NOT_USED');
        }

        fn after_swap(
            ref self: ContractState,
            caller: ContractAddress,
            pool_key: PoolKey,
            params: SwapParameters,
            delta: Delta
        ) {
            assert(false, 'NOT_USED');
        }

        fn before_update_position(
            ref self: ContractState,
            caller: ContractAddress,
            pool_key: PoolKey,
            params: UpdatePositionParameters
        ) {
            assert(false, 'NOT_USED');
        }

        fn after_update_position(
            ref self: ContractState,
            caller: ContractAddress,
            pool_key: PoolKey,
            params: UpdatePositionParameters,
            delta: Delta
        ) {
            assert(false, 'NOT_USED');
        }
    }
}