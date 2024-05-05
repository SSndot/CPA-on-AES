load("pts.mat")
load("cipher.mat")
load("rsbox.mat")

cipher_num = 20000; % 密文数量
trace_num = 20000;  % 电源迹线数量
cipher_bytes = 16;  % 密文字节数
key_bytes = 16;     % 密钥字节数(128位)
trace_point = 100;  % 电源迹线点数

shift_matrix = [
    1, 6, 11, 16, ...
    5, 10, 15, 4, ...
    9, 14, 3, 8, ...
    13, 2, 7, 12
];
keys = zeros(1, key_bytes);
% 对每个字节进行CPA分析
for byte_i = 1 : key_bytes
    guess_key = zeros(1, 256);
    for guess_key_byte = 0 : 255
        hws = zeros(cipher_num, 1);
        for cipher_i = 1 : cipher_num
            c1 = hex2dec(cipher(cipher_i, byte_i*2-1));
            c2 = hex2dec(cipher(cipher_i, byte_i*2));
            c = bitshift(c1, 4) + bitand(c2, 15);   % 密文字节
            s = bitxor(c, guess_key_byte);
            s = reverse_Sbox(1, s+1);
            o_byte_i = shift_matrix(byte_i);
            o1 = hex2dec(cipher(cipher_i, o_byte_i*2-1));
            o2 = hex2dec(cipher(cipher_i, o_byte_i*2));
            o = bitshift(o1, 4) + bitand(o2, 15);   % 原密文字节
            % 计算汉明距离
            d = bitxor(s, o);
            hws(cipher_i, 1) = sum(bitget(d, 1:8));
        end

        rs = zeros(1, trace_point);
        % 计算相关度
        for point_i = 1 : trace_point
            rs(1, point_i) = corr((pts(point_i, :))', hws, 'type', 'Pearson');
        end
        guess_key(1, guess_key_byte + 1) = max(rs);
    end
    [max_value, max_index] = max(guess_key);
    keys(1, byte_i) = max_index - 1;
end
if (keys(1, 1) == 0x53) && (keys(1, 7) == 0x2B)
    msg = strcat("Correct: ", num2str(keys));
    disp(msg);
    master_key = BackstepKey(keys);
    disp("Master Key:");
    disp(master_key);
else
    msg = strcat("Error: ", num2str(keys));
    disp(msg)
end



