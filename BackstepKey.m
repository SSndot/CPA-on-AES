% k[7] = k[3] ^ k[6]     ->  k[3] = k[7] ^ k[6]
% k[6] = k[2] ^ k[5]     ->  k[2] = k[6] ^ k[5]
% k[5] = k[1] ^ k[4]     ->  k[1] = k[5] ^ k[4]
% k[4] = k[0] ^ T(k[3])  ->  k[0] = k[4] ^ T(k[3])

function master_key = BackstepKey(A)
Rcon = load('rcon.mat').Rcon;
    master_key = zeros(4, 4);
    keys = zeros(4, 44);
    index = 1;
    % 将第10轮的key放入keys中
    for col = 1:4
        for row = 1:4
            keys(row, 40+col) = A(index);  % 将A的元素放入B对应的位置
            index = index + 1;  % 更新A数组的索引
        end
    end
    for i = 10:-1:1
        keys(:, i*4) = bitxor(keys(:, i*4+4), keys(:, i*4+3));
        keys(:, i*4-1) = bitxor(keys(:, i*4+3), keys(:, i*4+2));
        keys(:, i*4-2) = bitxor(keys(:, i*4+2), keys(:, i*4+1));
        keys(:, i*4-3) = bitxor(uint8(keys(:, i*4+1)), uint8(GetKey(keys(:, i*4), Rcon(:, i))));
    end
    master_key(:, 1) = keys(:, 1);
    master_key(:, 2) = keys(:, 2);
    master_key(:, 3) = keys(:, 3);
    master_key(:, 4) = keys(:, 4);
end

function A_key = GetKey(A, rcon)
Sbox = load("sbox.mat").Sbox;
    A_rw = [A(2:end); A(1)];
    A_sb = Sbox(1, A_rw+1)';
    A_key = bitxor(uint8(A_sb), uint8(rcon));
end


    