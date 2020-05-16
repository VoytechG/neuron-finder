
a = myFun(1);

function output = myFun(input)

    output = myFun2(input + 1);


    function output2 = myFun2(input)
        output2 = input + 1;
        warning('warning description +'));
    end
end