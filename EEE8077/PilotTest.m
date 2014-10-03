clear all; clc;

N = 2048;
D = [1:N];
p_value = 0;
p_rate = 8;

Dp_Size = N+(idivide(int32(N),p_rate-1));
Dp_LastData = idivide(int32(Dp_Size),p_rate) - mod(Dp_Size, p_rate);

for i=(1:p_rate:Dp_Size)
	Dp(i) = p_value;
    if i < N+Dp_LastData
        for k=(i+1:i+(p_rate-1))
            Dp(k) = D(k - (idivide(k-1,int32(p_rate))+1));
        end
    else
        for k=(i+1:Dp_Size+1)
            Dp(k) = D(k - (idivide(k-1,int32(p_rate))+1));
        end
    end
end