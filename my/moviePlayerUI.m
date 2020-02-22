close all force
prompt = 'What is the original value? ';
x = input(prompt);
y = x*10;

buttonPlot(movie);

function buttonPlot(movie)
  fig = uifigure;

  ax = uiaxes('Parent',fig,...
      'Units','pixels',...
      'Position', [104, 123, 250, 250]);
  
  playMovie(ax, movie);

  btn = uibutton(fig,'push',...
      'Position',[420, 218, 100, 22],...
      'ButtonPushedFcn', @(btn,event) disp('click'));
end

function playMovie(ax, movie)
  for i = 1:20
    imagesc(ax, movie(:,:, i));
    colormap(ax,gray);
    patch(ax, [0 .5 1] * 10 + i * 10, [0 1 0] * 10 + i *10, [1 0 0]);
    disp(i)
    pause(0.1)
  end
end


function helperPatch(i)
  patch([0 .5 1] * 10 + i * 10, [0 1 0] * 10 + i *10, [1 0 0]);
  disp(i)
end