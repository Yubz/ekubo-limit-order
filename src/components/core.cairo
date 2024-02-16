use ekubo::interfaces::core::{ICoreDispatcher, ICoreDispatcherTrait};
use ekubo::interfaces::positions::{IPositionsDispatcher, IPositionsDispatcherTrait};
use ekubo::types::keys::{PositionKey, PoolKey};
use ekubo::types::bounds::{Bounds};
use ekubo::types::i129::{i129};
use core::traits::{TryInto, Into};
use core::option::{OptionTrait};
use starknet::ContractAddress;
use alexandria_storage::list::{List, ListTrait};

#[starknet::interface]
trait IEkuboLimitOrder<TContractState> {
    // Get limit orders of caller address
    fn get_limit_orders(self: @TContractState) -> Array<u64>;

    // Set a limit order 
    fn set_limit_order(ref self: TContractState, pool_key: PoolKey, bounds: Bounds, min_liquidity: u128);
}

#[starknet::contract]
mod LimitOrder {
    use core::result::ResultTrait;
    use super::{IEkuboLimitOrder, PositionKey, PoolKey, i129, TryInto, Into, List, ListTrait, Bounds};
    use core::array::{Array, ArrayTrait};
    use ekubo::types::call_points::{CallPoints};
    use ekubo::types::delta::{Delta};
    use ekubo::interfaces::core::{ICoreDispatcher, ICoreDispatcherTrait, IExtension, SwapParameters, UpdatePositionParameters};
    use ekubo::interfaces::positions::{IPositionsDispatcher, IPositionsDispatcherTrait};
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address};
    
    #[storage]
    struct Storage {
        core: ICoreDispatcher,
        positions: IPositionsDispatcher,
        limit_orders: LegacyMap<ContractAddress, List<u64>>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, core: ContractAddress, positions: ContractAddress) {
        self.core.write(ICoreDispatcher { contract_address: core });
        self.positions.write(IPositionsDispatcher { contract_address: positions });
    }

    #[abi(embed_v0)]
    impl EkuboLimitOrderImpl of IEkuboLimitOrder<ContractState> {
        fn get_limit_orders(self: @ContractState) -> Array<u64> {
            self.limit_orders.read(get_caller_address()).array().unwrap()
        }

        fn set_limit_order(ref self: ContractState, pool_key: PoolKey, bounds: Bounds, min_liquidity: u128) {
            let (position_id, _liquidity) = self.positions.read().mint_and_deposit(pool_key, bounds, min_liquidity);
            
            let mut limit_orders = self.limit_orders.read(get_caller_address());
            limit_orders.append(position_id);
        }
    }

    #[abi(embed_v0)]
    impl EkuboLimitOrderExtension of IExtension<ContractState> {
        fn before_initialize_pool(
            ref self: ContractState, caller: ContractAddress, pool_key: PoolKey, initial_tick: i129
        ) -> CallPoints {
            assert(self.core.read().contract_address == get_caller_address(), 'CALLER_NOT_CORE');

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