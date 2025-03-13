`timescale 1us / 1ps

module ARTAU(
    input radar_echo,
    input scan_for_target,
    input [31:0] jet_speed,
    input [31:0] max_safe_distance,
    input RST,
    input CLK,
    output reg radar_pulse_trigger,
    output reg [31:0] distance_to_target,
    output reg threat_detected,
    output reg [1:0] ARTAU_state
);


parameter IDLE = 2'b00;
parameter EMIT = 2'b01;
parameter LISTEN = 2'b10;
parameter ASSESS = 2'b11;

// Internal signals
reg [31:0] round_trip_time;
reg [31:0] elapsed_time;
reg [31:0] old_distance_to_target;
reg [31:0] distance_difference;
reg [31:0] temp_velocity;
reg [31:0] relative_velocity;
reg [31:0] pulse_count; // Added pulse_count variable
reg [31:0] pulse_emission_timer; // Added pulse_emission_timer variable
reg [31:0] listen_to_echo_timer; // Added listen_to_echo_timer variable
reg [31:0] status_update_timer; // Added status_update_timer variable

// State register
reg [1:0] next_state;

// Initialize signals
initial begin
    ARTAU_state = IDLE;
    next_state = IDLE;
    radar_pulse_trigger = 0;
    distance_to_target = 0;
    threat_detected = 0;
    pulse_count = 0; // Initialize pulse_count
    pulse_emission_timer = 0; // Initialize pulse_emission_timer
    listen_to_echo_timer = 0; // Initialize listen_to_echo_timer
end
reg clk = 0;
always #1 clk = ~clk;
// State transition and logic
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        ARTAU_state <= IDLE;
        radar_pulse_trigger <= 0;
        distance_to_target <= 0;
        threat_detected <= 0;
        pulse_count <= 0; // Reset pulse_count on reset
        pulse_emission_timer <= 0; // Reset pulse_emission_timer on reset
        listen_to_echo_timer <= 0; // Reset listen_to_echo_timer on reset
        status_update_timer <= 0; // Reset status_update_timer on reset
    end else begin
        ARTAU_state <= next_state;
        listen_to_echo_timer <= (ARTAU_state == LISTEN) ? listen_to_echo_timer + 1 : 0;
        status_update_timer <= 0; // Reset status_update_timer when transitioning to a new state
    end
end

// State logic
always @(clk) begin
    elapsed_time = $time;
    case (ARTAU_state)
        IDLE: begin
            if (scan_for_target & ARTAU_state==next_state) begin
                next_state = EMIT;
                radar_pulse_trigger <= 1;
                pulse_count <= pulse_count + 1; // Increment pulse_count on trigger
                pulse_emission_timer <= $time; // Start pulse_emission_timer
            end 
        end

        EMIT: begin
            radar_pulse_trigger <= 1;
            if (($time - pulse_emission_timer) >= 300 & ARTAU_state==next_state) begin
                radar_pulse_trigger <= 0;
                next_state = LISTEN;
                listen_to_echo_timer <= 0; // Start listen_to_echo_timer
            end
        end

        LISTEN: begin
            if (radar_echo == 1 && pulse_count == 2 & ARTAU_state==next_state) begin
                round_trip_time <= $time - listen_to_echo_timer; // Measure echo listening time
                distance_to_target <= (round_trip_time * 3) / 2;
                if (listen_to_echo_timer == 0) begin
                    old_distance_to_target <= distance_to_target;
                end
                next_state = (listen_to_echo_timer == 0) ? EMIT : ASSESS;
                status_update_timer <= 0; // Reset status_update_timer when transitioning to ASSESS
            end else if (($time - listen_to_echo_timer) >= 2000 & ARTAU_state==next_state) begin
                next_state = IDLE;
            end
        end

        ASSESS: begin
            threat_detected <= 0;
            if (scan_for_target & ARTAU_state==next_state) begin
                next_state = EMIT;
                radar_pulse_trigger <= 1;
                pulse_count <= pulse_count + 1; // Increment pulse_count on trigger
                status_update_timer <= 0; // Reset status_update_timer when transitioning to EMIT
            end else if (listen_to_echo_timer >= 3000 & ARTAU_state==next_state) begin
                next_state = IDLE;
            end else  begin
                distance_difference = distance_to_target - old_distance_to_target;
                temp_velocity = distance_difference / (round_trip_time / 2); // Calculate relative velocity
                relative_velocity = jet_speed - temp_velocity;

                if (distance_difference + (jet_speed * (round_trip_time / 2)) - old_distance_to_target < 0 & ARTAU_state==next_state) begin
                    threat_detected <= 1;
                    status_update_timer <= $time; // Start status_update_timer
                end else if ( ARTAU_state==next_state)begin
                    threat_detected <= 0;
                    status_update_timer <= 0; // Reset status_update_timer when no threat
                end
            end
        end
    endcase
end


endmodule
