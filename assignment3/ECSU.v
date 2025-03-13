`timescale 1us / 1ps

module ECSU(
    input CLK,
    input RST,
    input thunderstorm,
    input [5:0] wind,
    input [1:0] visibility,
    input signed [7:0] temperature,
    output reg severe_weather,
    output reg emergency_landing_alert,
    output reg [1:0] ECSU_state
);



// Define states
parameter clear = 2'b00;
parameter caut = 2'b01;
parameter alert = 2'b10;
parameter emergcy = 2'b11;

// Internal signals
reg [1:0] afterstate;
reg rst = 0;
// State register
always @(posedge CLK or posedge RST) begin
    if (RST)begin
        rst = 1;
    end
    if (CLK) begin
        if (rst)begin
            rst = 0;
            afterstate = clear;
            severe_weather = 0;
            emergency_landing_alert = 0;
        end
        ECSU_state <= afterstate;
    end
end

// Output registers
always @(posedge CLK ) begin

    if (CLK) begin
        case (ECSU_state)
            clear: begin

                severe_weather <= (wind > 15) || (temperature < -35) || (temperature > 35) || (thunderstorm) || (visibility == 3);
                if(wind > 10 && wind <= 15 && visibility == 1) begin
                    severe_weather <= 0;
                    afterstate = caut;
                end
            end
            caut: begin
                severe_weather <= (wind > 15) || (temperature < -35) || (temperature > 35) || (thunderstorm) || (visibility == 3);
                if(wind <= 10 && visibility == 0) begin
                    severe_weather <= 0;
                    afterstate = clear;
                end
            end
            alert: begin
                    severe_weather <= (wind > 20) || (temperature < -40) || (temperature > 40);
                    if(wind <= 10 && temperature >= -35 && temperature <= 35 && thunderstorm == 0 && visibility == 1) begin
                        severe_weather <= 0;
                        afterstate = caut;
                    end
                     if(wind > 20 || temperature < -40 || temperature > 40) begin
                        severe_weather <= 1;
                        afterstate = emergcy;
                    end


            end
            emergcy: begin
                 if(ECSU_state == emergcy) begin
                    severe_weather <= (wind > 20) || (temperature < -40) || (temperature > 40);
                    afterstate = emergcy;
                end
                emergency_landing_alert <= (ECSU_state == emergcy);
            end
        endcase
    end
end

// State transition logic
always @* begin
    case (ECSU_state)
        clear: begin
            if((wind > 15) || (temperature < -35) || (temperature > 35) || (wind > 15) || (thunderstorm) || (visibility == 3)) begin
                afterstate = alert;
                severe_weather <= 1;
            end
            else if((wind > 10) || (visibility == 1)) begin
                afterstate = caut;
                severe_weather <= 0;
            end
            else begin
                afterstate = clear;
                severe_weather <= 0;
            end
        end
        caut: begin
            if((wind <= 10) && (visibility == 0)) begin
                afterstate = clear;
                severe_weather <= 0;
            end
            else if((wind > 15) || (thunderstorm) || (visibility == 3) || (temperature < -35) || (temperature > 35)) begin
                afterstate = alert;
                severe_weather <= 1;
            end
            else begin
                afterstate = caut;
                severe_weather <= 0;
            end
        end
        alert: begin
                if((temperature >= -35) && (temperature <= 35) && (wind <= 10) && !thunderstorm && (visibility <= 1)) begin
                    afterstate = caut;
                    severe_weather <= 0;
                end
                else if((temperature < -40) || (temperature > 40) || (wind > 20)) begin
                    afterstate = emergcy;
                    emergency_landing_alert <= 1;
                end

                else begin
                    afterstate = alert;
                    severe_weather <= 1;
                end
            end
        emergcy: begin
            emergency_landing_alert <= 1;
            afterstate = emergcy;
        end
        default: begin
            severe_weather <= severe_weather;
        end

    endcase
end


endmodule