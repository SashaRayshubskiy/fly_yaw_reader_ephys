function [currentA, voltageA, currentB, voltageB] = get_dual_scaled_voltage_and_current( trial_data, GET_B )

currentB = [];
voltageB = [];

[ currentA, voltageA ] = get_scaled_voltage_and_current_A( trial_data );

if (nargin == 1)
    GET_B = 0;
end

if( GET_B == 1 )
    [ currentB, voltageB ] = get_scaled_voltage_and_current_B( trial_data );
end

end

