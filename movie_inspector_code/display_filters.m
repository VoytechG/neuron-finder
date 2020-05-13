run("loadExtractionResults.m")

start = 450;
play(filters, start);

function play(filters, start)

  play = true;

  for i = start:size(filters, 3)
    imagesc(filters(:, :, i));
    setTitle(i);

    set(gcf, 'KeyPressFcn', @onKeyPress);

    if play
      pause(1/5);
    else
      break;
    end



  end


 function onKeyPress(~, event)
    keyPressed = event.Key;
    
    if strcmp(keyPressed, 'p')
      play = false;
    elseif strcmp(keyPressed, 'q')
      play = false;
      close
    end

 end

 function setTitle(frameIndex)

       

        title(gca, {
          sprintf('Frame %d \n', frameIndex) 
        });
    end

end

