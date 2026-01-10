/// DAY 21: Final Tests & Cleanup
/// 
/// Today you will:
/// 1. Write comprehensive tests for the farm
/// 2. Clean up your code
/// 3. Review what you've learned
///
/// Note: You can copy code from day_20/sources/solution.move if needed

module challenge::day_21 {
    use sui::event;
	#[test_only]
    use sui::test_scenario;
	#[test_only]
    use std::unit_test::assert_eq;

    // Note: test_scenario is available in Sui framework for testing
    // You'll need to import it when writing tests: use sui::test_scenario;

    // Copy from day_20: All structs and functions
    
    const MAX_PLOTS: u64 = 20;
    const E_PLOT_NOT_FOUND: u64 = 1;
    const E_PLOT_LIMIT_EXCEEDED: u64 = 2;
    const E_INVALID_PLOT_ID: u64 = 3;
    const E_PLOT_ALREADY_EXISTS: u64 = 4;
    

    public struct FarmCounters has copy, drop, store {
        planted: u64,
        harvested: u64,
        plots: vector<u8>,
    }

    fun new_counters(): FarmCounters {
        FarmCounters {
            planted: 0,
            harvested: 0,
            plots: vector::empty(),
        }
    }

    fun plant(counters: &mut FarmCounters, plotId: u8) {
        // Check if plotId is valid (between 1 and 20)
        assert!(plotId >= 1 && plotId <= (MAX_PLOTS as u8), E_INVALID_PLOT_ID);
        
        // Check if we've reached the plot limit
        let len = vector::length(&counters.plots);
        assert!(len < MAX_PLOTS, E_PLOT_LIMIT_EXCEEDED);
        
        // Check if plot already exists in the vector
        let mut i = 0;
        while (i < len) {
            let existing_plot = vector::borrow(&counters.plots, i);
            assert!(*existing_plot != plotId, E_PLOT_ALREADY_EXISTS);
            i = i + 1;
        };
        
        counters.planted = counters.planted + 1;
        vector::push_back(&mut counters.plots, plotId);
    }

    fun harvest(counters: &mut FarmCounters, plotId: u8) {
        let len = vector::length(&counters.plots);
                
        // Check if plot exists in the vector and find its index
        let mut i = 0;
        let mut found_index = len; 
        while (i < len) {
            let existing_plot = vector::borrow(&counters.plots, i);
            if (*existing_plot == plotId) {
                found_index = i;
            };
            i = i + 1;
        };
        
        // Assert that plot was found (found_index < len means we found it)
        assert!(found_index < len, E_PLOT_NOT_FOUND);
        
        // Remove the plot from the vector
        vector::remove(&mut counters.plots, found_index);
        counters.harvested = counters.harvested + 1;
    }

    public struct Farm has key {
        id: UID,
        counters: FarmCounters,
    }

    fun new_farm(ctx: &mut TxContext): Farm {
        Farm {
            id: object::new(ctx),
            counters: new_counters(),
        }
    }

    entry fun create_farm(ctx: &mut TxContext) {
        let farm = new_farm(ctx);
        transfer::share_object(farm);
    }

    fun plant_on_farm(farm: &mut Farm, plotId: u8) {
        plant(&mut farm.counters, plotId);
    }

    fun harvest_from_farm(farm: &mut Farm, plotId: u8) {
        harvest(&mut farm.counters, plotId);
    }

    fun total_planted(farm: &Farm): u64 {
        farm.counters.planted
    }

    // Used in tests (see solution.move)
    fun total_harvested(farm: &Farm): u64 {
        farm.counters.harvested
    }

    public struct PlantEvent has copy, drop {
        planted_after: u64,
    }

    entry fun plant_on_farm_entry(farm: &mut Farm, plotId: u8) {
        plant_on_farm(farm, plotId);
        let planted_count = total_planted(farm);
        event::emit(PlantEvent {
            planted_after: planted_count,
        });
    }

    entry fun harvest_from_farm_entry(farm: &mut Farm, plotId: u8) {
        harvest_from_farm(farm, plotId);
    }

    // TODO: Write comprehensive tests:
    // 
    // Test 1: test_create_farm
    // - Create a farm (shared object)
    // - Check initial counters are zero
    // - Use test_scenario::take_shared to get the farm
	#[test]
	fun test_create_farm() {
		let mut scenario = test_scenario::begin(@0x1);
		{
			create_farm(test_scenario::ctx(&mut scenario));
		};
		test_scenario::next_tx(&mut scenario, @0x1);
		{
			let farm = test_scenario::take_shared<Farm>(&scenario);

			assert_eq!(total_planted(&farm), 0);
			assert_eq!(total_harvested(&farm), 0);
			test_scenario::return_shared(farm);
		};
		test_scenario::end(scenario);
	}

    // Test 2: test_planting_increases_counter
    // - Create farm, plant plotId 1
    // - Verify planted counter is 1
    // - Use test_scenario::take_shared and test_scenario::return_shared
	#[test]
	fun	test_planting_increases_counter() {
		let mut scenario = test_scenario::begin(@0x1);
		{
			create_farm(test_scenario::ctx(&mut scenario));
		};
		test_scenario::next_tx(&mut scenario, @0x1);
		{
			let mut farm = test_scenario::take_shared<Farm>(&scenario);
			plant_on_farm(&mut farm, 1);

			assert_eq!(total_planted(&farm), 1);
			assert_eq!(total_harvested(&farm), 0);
			test_scenario::return_shared(farm);
		};
		test_scenario::end(scenario);
	}

    // Test 3: test_harvesting_increases_counter
    // - Create farm, plant plotId 1, then harvest plotId 1
    // - Verify both counters are 1
	#[test]
	fun test_harvesting_increases_counter() {
		let mut scenario = test_scenario::begin(@0x1);
		{
			create_farm(test_scenario::ctx(&mut scenario));
		};
		test_scenario::next_tx(&mut scenario, @0x1);
		{
			let mut farm = test_scenario::take_shared<Farm>(&scenario);
			plant_on_farm(&mut farm, 1);
			harvest_from_farm(&mut farm, 1);

			assert_eq!(total_planted(&farm), 1);
			assert_eq!(total_harvested(&farm), 1);
			test_scenario::return_shared(farm);
		};
		test_scenario::end(scenario);
	}

    // Test 4: test_multiple_operations
    // - Plant plotIds 3, 5, 18 (in any order)
    // - Harvest plotId 5
    // - Verify planted counter is 3, harvested counter is 1
	#[test]
	fun test_multiple_operations() {
		let mut scenario = test_scenario::begin(@0x1);
		{
			create_farm(test_scenario::ctx(&mut scenario));
		};
		test_scenario::next_tx(&mut scenario, @0x1);
		{
			let mut farm = test_scenario::take_shared<Farm>(&scenario);
			plant_on_farm(&mut farm, 3);
			plant_on_farm(&mut farm, 5);
			plant_on_farm(&mut farm, 18);
			harvest_from_farm(&mut farm, 5);

			assert_eq!(total_planted(&farm), 3);
			assert_eq!(total_harvested(&farm), 1);
			test_scenario::return_shared(farm);
		};
		test_scenario::end(scenario);
	}

    // Test 5: test_invalid_plot_id
    // - Try to plant plotId 0 or 21 (should abort)
	#[test]
	#[expected_failure(abort_code = E_INVALID_PLOT_ID)]
	fun test_invalid_plot_id() {
		let mut scenario = test_scenario::begin(@0x1);
		{
			create_farm(test_scenario::ctx(&mut scenario));
		};
		test_scenario::next_tx(&mut scenario, @0x1);
		{
			let mut farm = test_scenario::take_shared<Farm>(&scenario);
			plant_on_farm(&mut farm, 21);

			test_scenario::return_shared(farm);
		};
		test_scenario::end(scenario);
	}

    // Test 6: test_duplicate_plot
    // - Plant plotId 1, then try to plant plotId 1 again (should abort)
	#[test]
	#[expected_failure(abort_code = E_PLOT_ALREADY_EXISTS)]
	fun test_duplicate_plot() {
		let mut scenario = test_scenario::begin(@0x1);
		{
			create_farm(test_scenario::ctx(&mut scenario));
		};
		test_scenario::next_tx(&mut scenario, @0x1);
		{
			let mut farm = test_scenario::take_shared<Farm>(&scenario);
			plant_on_farm(&mut farm, 1);
			plant_on_farm(&mut farm, 1);

			test_scenario::return_shared(farm);
		};
		test_scenario::end(scenario);
	}

    // Test 7: test_plot_limit
    // - Try to plant 21 plots (should abort on the 21st)
	#[test]
	#[expected_failure(abort_code = E_PLOT_LIMIT_EXCEEDED)]
	fun test_plot_limit() {
		let mut scenario = test_scenario::begin(@0x1);
		{
			create_farm(test_scenario::ctx(&mut scenario));
		};
		test_scenario::next_tx(&mut scenario, @0x1);
		{
			let mut farm = test_scenario::take_shared<Farm>(&scenario);
			let mut i;

			i = 1;
			while (i <= 20)
			{
				plant_on_farm(&mut farm, i);
				i = i + 1;
			};
			plant_on_farm(&mut farm, 1);
			test_scenario::return_shared(farm);
		};
		test_scenario::end(scenario);
	}

    // Test 8: test_harvest_nonexistent_plot
    // - Try to harvest a plot that doesn't exist (should abort)
	#[test]
	#[expected_failure(abort_code = E_PLOT_NOT_FOUND)]
	fun test_harvest_nonexistent_plot() {
		let mut scenario = test_scenario::begin(@0x1);
		{
			create_farm(test_scenario::ctx(&mut scenario));
		};
		test_scenario::next_tx(&mut scenario, @0x1);
		{
			let mut farm = test_scenario::take_shared<Farm>(&scenario);
			harvest_from_farm(&mut farm, 2);

			test_scenario::return_shared(farm);
		};
		test_scenario::end(scenario);
	}

    // Use test_scenario::begin, test_scenario::next_tx, test_scenario::take_shared, etc.
    // Note: Since farm is a shared object, use test_scenario::take_shared instead of take_from_sender

    // TODO: Review all three projects (habit_tracker, bounty_board, farm_simulator)
    // Make sure function names are consistent
    // Remove any unnecessary comments
    // Ensure all tests pass
}

