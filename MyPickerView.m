

int i;
int randomRow;
NSTimer *timer;

static int staticRow = 0;
static int j = 0;

-(void)viewDidLoad{
    [super viewDidLoad];
    
    selectPlayerpickerView.delegate = self;
    [selectPlayerpickerView setValue:[UIColor whiteColor] forKey:@"textColor"];
    selectPlayerpickerView.dataSource = self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    j = 15;
    i = randomRow = 0;
    lblSelectedPlayerName.alpha = 0.0;
    imgShake.alpha = 1.0;
    isScrollComplete = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[UIView new]];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(scroll) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
    timer = nil;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _arrPlayer.count;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_arrPlayer objectAtIndex:row];
}

-(void)scroll
{
    //Master Logic. for slow down picker view.
    // 😊
       if (i%2==0)
       {
           [selectPlayerpickerView selectRow:(staticRow = staticRow + (j--)) inComponent:0 animated:YES];
       }
       else
       {
           [selectPlayerpickerView selectRow:(staticRow = staticRow + (j--)) inComponent:0 animated:YES];
       }
        i++;
    if (i%15==0)
    {
        randomRow = arc4random() % [_arrPlayer count];
        isScrollComplete = YES;
        [selectPlayerpickerView selectRow:randomRow inComponent:0 animated:YES];
        [self pickerView:selectPlayerpickerView didSelectRow:randomRow  inComponent:0];
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    imgShake.alpha = 0.0;
    
    if (isScrollComplete)
    {
        [timer invalidate];
        timer = nil;
        
        [UIView animateWithDuration:3.0 animations:^{
            lblSelectedPlayerName.text = [_arrPlayer objectAtIndex:(int)randomRow];
            lblSelectedPlayerName.alpha = 1.0;
        } completion:^(BOOL finished) {
                [self performSegueWithIdentifier:@"PLAYERSELECTED" sender:nil];
        }];
        
        return;
    }    
}

@end
