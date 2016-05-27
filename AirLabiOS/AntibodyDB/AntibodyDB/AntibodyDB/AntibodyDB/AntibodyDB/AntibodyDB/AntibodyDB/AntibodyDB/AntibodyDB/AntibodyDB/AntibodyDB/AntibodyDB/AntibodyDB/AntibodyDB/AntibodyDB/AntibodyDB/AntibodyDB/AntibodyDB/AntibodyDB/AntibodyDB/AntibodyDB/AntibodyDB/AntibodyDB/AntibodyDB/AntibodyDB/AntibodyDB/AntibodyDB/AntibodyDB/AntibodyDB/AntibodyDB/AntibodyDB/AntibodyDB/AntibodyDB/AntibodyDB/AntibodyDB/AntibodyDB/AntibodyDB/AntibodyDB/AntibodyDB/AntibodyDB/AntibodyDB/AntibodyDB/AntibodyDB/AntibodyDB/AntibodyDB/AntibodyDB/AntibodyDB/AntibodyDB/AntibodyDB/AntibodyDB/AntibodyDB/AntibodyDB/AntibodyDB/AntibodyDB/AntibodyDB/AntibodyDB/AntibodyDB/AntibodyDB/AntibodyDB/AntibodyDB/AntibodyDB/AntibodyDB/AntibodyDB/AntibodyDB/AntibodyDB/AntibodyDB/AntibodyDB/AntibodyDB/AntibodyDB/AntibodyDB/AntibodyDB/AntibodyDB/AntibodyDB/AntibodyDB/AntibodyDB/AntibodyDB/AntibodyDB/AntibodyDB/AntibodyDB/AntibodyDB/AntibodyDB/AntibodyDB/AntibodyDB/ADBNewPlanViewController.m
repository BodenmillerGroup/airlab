//
//  ADBNewPlanViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 6/5/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBNewPlanViewController.h"

@interface ADBNewPlanViewController ()

@property (nonatomic, strong) Plan *plan;

@end

@implementation ADBNewPlanViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPlan:(Plan *)plan
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.plan = plan;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(NSFetchedResultsController *)fetchedResultsController{
    if(!_fetchedResultsController){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:PERSON_DB_CLASS];
        request.predicate = [NSPredicate predicateWithFormat:@"ANY groupPersons.group == %@", [[ADBAccountManager sharedInstance]currentGroupPerson].group];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"perPersonId" ascending:YES]];
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];//TODO add section name keypath with protein or epitope
        self.fetchedResultsController = controller;
    }
    return _fetchedResultsController;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fetchedResultsController.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    Person *per = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = per.perLastname;
    cell.detailTextLabel.text = per.perEmail;
    if (per == [[ADBAccountManager sharedInstance]currentUser]) {
        cell.textLabel.textColor = [UIColor redColor];
        cell.detailTextLabel.textColor = [UIColor redColor];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        if ([_plan.groupPersons containsObject:per]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}

-(void)add{
    
    NSString *message = [General returnMessageAftercheckName:_namePlan.text lenghtTo:20];
    if(message){[General showOKAlertWithTitle:message andMessage:nil];return;}
    
    if(self.plan){
    }else{
        self.plan = (Plan *)[General newObjectOfType:PLAN_DB_CLASS saveContext:NO];
    }
    _plan.plnTitle = _namePlan.text;
    
    [self.delegate didAddPlan:_plan];
}


@end
