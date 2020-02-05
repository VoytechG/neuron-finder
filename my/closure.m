a = ones(4,5, 'int8') + 2;

a = iii(a);

a

function a = iii(a)
 
    for i = 1:4
        a(1, i) = i;
    end
    
    a
end

