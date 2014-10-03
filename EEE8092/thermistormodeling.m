clear all;
clc;

% data
temps = [0 25 50];
therm = [15000 5000 1794];
r1    = [5000 10000];
vt_5k = (3.3*therm)./(r1(1)+therm);
vt_10k= (3.3*therm)./(r1(2)+therm);

% linear line
x = [0:0.01:3.3];
m_5 = -31.5;
c_5 = 77;
y_5 = m_5*x + c_5;
m_10 = -33.5;
c_10 = 65;
y_10 = m_10*x + c_10;

% plotting
hold on;
plot(vt_5k, temps, 'go');
plot(vt_10k, temps, 'ro');
plot(x, y_5, 'g--');
plot(x, y_10, 'r--');
legend
ylabel('Temperature');
xlabel('Voltage Vt');
title('Why current R1 value is wrong!');
legend('5k', '10k');