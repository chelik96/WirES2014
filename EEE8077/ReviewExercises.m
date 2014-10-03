%*******************************************************************************
% Matlab Review Exercises 1
%*******************************************************************************

%1
(-3)^2 - (4*2*5)

%2
cos(2*pi/3) %2i
sin(pi/8)   %2ii
acos(0.5)   %2iii
atan(pi/2)  %2iv

%3
a=(1+2j)*(3+5j)/(8+j) %3i
sqrt(real(a)^2+imag(a)^2) %3ii
atan2(imag(a),real(a))*(180/pi) %3iii
b=(3+2j)*(1+j)/((1+3j)*conj((2+j))) %3i
sqrt(real(b)^2+imag(b)^2) %3ii
atan2(imag(b),real(b))*(180/pi) %3iii

%4
H=(1/(1+(j*(150/100))))
Hmag = abs(H)
Hphase = radtodeg(angle(H))

%5
20*log10(Hmag) %or...
mag2db(Hmag) %or...
db(Hmag)

%6
s11 = 0.61*exp(j*165/180*pi);   %6 setup
s21 = 3.72*exp(j*59/180*pi);    %6 setup
s12 = 0.05*exp(j*42/180*pi);    %6 setup
s22 = 0.45*exp(j*(-48/180)*pi); %6 setup
D = s11*s22-s12*s21             %6 setup
K = (1-abs(s11)^2-abs(s22)^2+...
    (abs(D))^2)/...
    (2*abs(s12)*abs(s21))       %6a
Z0 = 50                         %6 setup
ZS = 10+20j                     %6 setup
ZL = 30-40j                     %6 setup
GammaS = (ZS-Z0)/(Z0+ZS)        %6 setup
GAnumer = abs(s21)^2*(1-abs(GammaS)^2) 
GAdenom = (1-abs(s22)^2)+...
        abs(GammaS)^2*(abs(s11)^2-abs(D)^2)-...
        2*real(GammaS*(s11-D*conj(s22)))
GA = GAnumer/GAdenom            %6b



%*******************************************************************************
% Matlab Review Exercises 1
%*******************************************************************************

% 1
[11:31]

% 2
x=0:9 %setup
y=0.1*[0:9] %setup
x(2:2:end)=x(2:2:end)+5 %2a
x(1:2:end)=x(1:2:end)+10 %2b
x.^2 %2ci
x.^(1/2) %2cii
y.^2 %2ciii
sqrt(y) %2civ
x=x.^y %2d
y=y./x %2e
z=x.*y %2f
w=sum(z) %2g
x*y'-w %2h - ans=0... interpretation: x*y-sum((x^y)*(y/x)) = 0...

% 3
x=randn(10) %setup
x(:,5)=3 %3a
x(:,5)=[] %3b
x(6,:)=2 %3c
x(6,:=[] %3d

% 4
R=[1 0.1 0.2; 0.1 1 0.1; 0.2 0.1 1] %4ai
v=[1;0;0] %4aii
inv(R) %4b
a=inv(R)*v %4c
det(R) %4di
eig(R) %4dii
[eigenvalues,eigenvectors]=eig(R) %4diii

% 5
x=5+2*randn(10^4,1); %5i
mean(x) %5ii, ans=4.9930 - approx 5 - verified mean
std(x) %5iii, ans=1.9985 - approx 2 - verified deviation
stem(x(1:100)) %5iv

% 6
A=sqrt(2) %setup
f_c=100 %setup
t = [0:0.05/(48000*0.05):0.05]; %6a
phi = rand(0,2*pi) %6b
y = A*sin(2*pi*f_c*t+phi) %6c
plot(t,y) %6d
mean(y) %6fi, ans = -4.3e-04 - approx 0
std(y) %6fii, ans = 1.0002 - approx 1
var(y) %6fiii, ans = 1.0005 - approx 1

%7
x=randsrc(1,1000,[-3 -1 1 3]); %7i
mean(x) %7ii, ans = 0.0520 - approx 0
std(x) %7iii, ans = 2.2312 - approx sqrt(5)
var(x) %7iv, and = 4.9783 - approx 5
x=randsrc(1,1000,[1+j,-1+j,-1-j,1-j]); %7v
mean(x) %7vi, ans = 0.0320 + 0.0400i - approx 0
std(x) %7vii, ans = 1.414 - approx sqrt(2)
var(x) %7viii, and = 1.9994 - approx 2



%*******************************************************************************
% Matlab Review Exercises 3
%*******************************************************************************

% 1
% a
y_b = [0.0201 0.0402 0.0201];
y_a = [1 -1.561 0.6414];
freqz(y_b,y_a);
impz(y_b,y_a);
% b
x=sin(2*pi*[0:0.05:4.999])+randn(1,100)*0.2;
% c -- easier solution: filter(y_b,y_a,x);
for n=1:100
  switch n
    case 1
      y(n)=0.0201*x(n);
    case 2
      y(n)=0.0201*x(n)+0.0402*x(n-1)+1.561*y(n-1);
    otherwise
      y(n)=0.0201*x(n)+0.0402*x(n-1)+0.0201*x(n-2)+1.561*y(n-1)-0.6414*y(n-2);
  end
end
% d
subplot(211), plot(x,'r-');
title('a) Filter Input');
ylabel('x(n)');
subplot(212), plot(y,'b-');
title('b) Filter output');
ylabel('y(n)');
xlabel('n (ms)');

% 2
% a
[d,constel]=bpsk(1,1000);
% b
w=0.4*randn(1,1000);
% c
x=d+w;
% d
plot(x,0,'ro');
title('BPSK Constellation');
axis([-2 2 -2 2])
ylabel('Quadrature');
xlabel('Inphase');
% e
dest=sign(x);
errors=0;
for n=1:length(d)
  if (d(n)~=dest(n))
    errors=errors+1;
  end
end
errors
