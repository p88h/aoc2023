fn call_closure[func: fn() capturing -> None]() -> None:
    func()

fn main():
    simpler = String("I want you to hold this")

    @parameter
    fn doit():
        for i in range(len(simpler)-5):
            print(simpler[i:i+5])   

    call_closure[doit]()
    # If uncommented, this will actually work correctly
    #print(len(simpler))