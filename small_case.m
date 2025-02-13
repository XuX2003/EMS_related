load small_case
G = graph(origin, destination, weight);
ID = [];
for i = 1: 100
    [id, ~] = nearest(G, i, 15);
    complent = 100 - length(id);
    id = [id; zeros(complent, 1)];
    ID = [ID, id];
end

for i = 1: 100
    ID(:, i) = sort(ID(:, i), 'descend');
end
ID = ID';

%% intlinprog求解器计算
C = ones(1, 100);
intcon = 1: 100;
A = zeros(100);
for i = 1: 100
    for j = 1: 100
        if ID(i, j) ~= 0
            index = ID(i, j);
            A(i, index) = 1;
        else
            continue
        end
    end
end
A = -A;
b = -ones(100, 1);
lb = zeros(1, 100);
ub = ones(1, 100);
[x, fval] = intlinprog(C, intcon, A, b, [], [], lb, ub);
location = find(x ~= 0);

%% CPLEX求解器计算
% 创建决策变量
x = binvar(1, 100);
% 添加约束条件
C = [];
for i = 1: 100
    refine = find(A(i, :) ~= 0);
    constraint = [sum(x(refine)) >= 1];
    C = [C; constraint];
end
% 配置
ops = sdpsettings('solver', 'CPLEX');
% 目标函数
z = sum(x); % 注意这是求解最大值
% 求解
reuslt = optimize(C,z);
if reuslt.problem == 0 % problem =0 代表求解成功
    value(x)
else
    disp('求解出错');
end