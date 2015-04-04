$ ->
    add-clicking-handler-to-all-buttons!
    add-clicking-handler-to-the-bubble!
    add-resetting-when-leave-apb!
    s1-wait-user-clicking!

s1-wait-user-clicking = !-> console.log "wait user clicking ..."

class Button
    @buttons = []
    @sum = 0;
    @disable-all-other-buttons = (this-button)-> [button.disable! for button in @buttons when button isnt this-button and button.state isnt 'done']
    @enable-all-other-buttons = (this-button)-> [button.enable! for button in @buttons when button isnt this-button and button.state isnt 'done']
    @all-button-is-done = ->
        [return false for button in @buttons when button.state isnt 'done']
        true
    @get-sum =-> return @sum
    @reset-all = !-> [button.reset! for button in @buttons]

    (@dom) !->
        @state = 'enabled';
        @red-dot = @dom.find \.unread
        @dom.click !~> if @state is 'enabled'
            @@@disable-all-other-buttons @
            @wait!
            @fetch-number-and-show!      
        @@@buttons.push @

    bubble-check:->
        if (@@@all-button-is-done!)
            $ '#info-bar' .add-class 'blue' .remove-class 'grey'
    fetch-number-and-show: !-> $.get '/api/random', (number, result)!~>
        if (@state is 'waiting') 
        then @red-dot .text number; @@@enable-all-other-buttons @; @@@sum+= parse-int number; console.log(@@@sum);@done!;@bubble-check!

    disable: !-> @state = 'disabled' ; @dom .add-class 'disabled'

    enable: !-> @state = 'enabled' ; @dom.remove-class 'disabled'

    wait: !-> 
        @red-dot .add-class 'appear'
        @state = 'waiting' ; 
        @dom.find '.unread' .text '...'

    done: !-> 
        @dom .add-class 'disabled'

        @state = 'done' 

    reset: !-> 
        @state = 'enabled' ; 
        @dom.remove-class 'disabled'
        @dom.find '.unread' .text '' .remove-class 'appear'
        @@@sum = 0;


add-clicking-handler-to-all-buttons = !-> 
    #btns = $ '#control-ring .button'
    for dom in $ '#control-ring .button'
        button = new Button ($ dom)

add-resetting-when-leave-apb = !->
    $ '#bottom-positioner' .on 'mouseleave' (event)!-> 
        Button.reset-all!
        bubble2 = $ '#info-bar'
        bubble2.text ''

add-clicking-handler-to-the-bubble = !->
    bubble = $ '#info-bar'
    bubble .remove-class 'blue' .add-class 'grey'
    bubble.click !-> if bubble.has-class 'blue'
        bubble.text Button.get-sum!
        bubble .remove-class 'blue' .add-class 'grey'