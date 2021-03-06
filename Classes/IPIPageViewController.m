//
//  IPIPageViewController.m
//  InsiderPages for iOS
//
//

#import "IPIPageViewController.h"
#import "IPIPageRankActionViewController.h"
#import "TTTAttributedLabel.h"
#import "IPIProviderRankTableViewCell.h"
#import "IPIProviderViewController.h"
#import "IPIPageTableViewHeader.h"
#import "IPISocialShareHelper.h"
#import "SVPullToRefresh.h"

//#import "CDIAddTaskView.h"
//#import "CDIAttributedLabel.h"
//#import "CDICreateListViewController.h"
#import "CDINoTasksView.h"
//#import "CDIRenameTaskViewController.h"
//#import "CDIWebViewController.h"
#import "UIColor+InsiderPagesiOSAdditions.h"
#import "UIColor-Expanded.h"
#import "UIFont+InsiderPagesiOSAdditions.h"

@interface IPIPageViewController () <IPIPageTableViewHeaderDelegate, IPIRankBarDelegate, TTTAttributedLabelDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@end

@implementation IPIPageViewController
@synthesize page = _page;

static CGFloat prevContentOffset = 0;

- (void)setPage:(IPKPage *)page {

	void *context = (__bridge void *)self;
	_page = page;
	self.title = self.page.name;
//	self.tableView.hidden = self.page == nil;
	
	if (_page == nil) {
		return;
	}
	
	[_page addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:context];
    [_page.owner addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:context];
    [_page addObserver:self forKeyPath:@"is_favorite" options:NSKeyValueObservingOptionNew context:context];
    [_page addObserver:self forKeyPath:@"is_following" options:NSKeyValueObservingOptionNew context:context];
    if (page.owner == nil) {
        [_page updateWithSuccess:^(){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.headerView setPage:_page];
                [self.headerView setNeedsDisplay];
            });
            if ([_page.owner isEqual:[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]]] || [_page.privacy_setting isEqualToNumber:@(0)] || _page.is_collaborator) {
                [self.tabButton setImage:[UIImage imageNamed:@"rank_tab"] forState:UIControlStateNormal];
            }else{
                [self.tabButton setImage:[UIImage imageNamed:@"locked_tab"] forState:UIControlStateNormal];
                [self.tabButton setUserInteractionEnabled:NO];
            }
        } failure:^(AFJSONRequestOperation * op, NSError * err){
            
        }];
    }
    
//	self.ignoreChange = YES;
    
    if ([_page.owner isEqual:[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]]] || [_page.privacy_setting isEqualToNumber:@(0)] || _page.is_collaborator) {
        [self.tabButton setImage:[UIImage imageNamed:@"rank_tab"] forState:UIControlStateNormal];
    }else{
        [self.tabButton setImage:[UIImage imageNamed:@"locked_tab"] forState:UIControlStateNormal];
        [self.tabButton setUserInteractionEnabled:NO];
    }
    
	[self.headerView setPage:_page];
    [self.headerView setNeedsDisplay];
}

- (void)setSortUser:(IPKUser *)sortUser{
    _sortUser = sortUser;
    [self.rankBar setSortUser:sortUser];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.ignoreChange = NO;
        [self.tableView reloadData];
    });
    [SSRateLimit executeBlock:[self refresh] name:@"refresh-add-to-pages" limit:0.0];

    if (_sortUser.name == nil) {
        [_sortUser updateWithSuccess:^(){
            [SSRateLimit executeBlock:[self refresh] name:@"refresh-add-to-pages" limit:0.0];
            
        } failure:^(AFJSONRequestOperation * op, NSError * err){
            
        }];
    }
}

//-(UITableView*)tableView{
//    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
//    [tableView setContentInset:UIEdgeInsetsMake(44.0f, 0.0f, 0.0f, 0.0f)];
//    
//    [tableView setContentOffset:CGPointMake(0.0f, 180.0f)];
//    tableView.dataSource = self;
//    tableView.delegate = self;
//    return tableView;
//}

#pragma mark - NSObject

- (id)init {
	if ((self = [super init])) {
//		self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tasks" style:UIBarButtonItemStyleBordered target:nil action:nil];
	}
	return self;
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    self.tableView.showsInfiniteScrolling = NO;
	
//	self.view.backgroundColor = [UIColor cheddarArchesColor];
//	self.tableView.hidden = self.page == nil;
    [self.tableView setAllowsSelectionDuringEditing:YES];
//	self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake([CDIAddTaskView height], 0.0f, 0.0f, 0.0f);
	self.pullToRefreshView.bottomBorderColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
     [self.tableView setFrame:CGRectMake(15, 165, 290, [UIScreen mainScreen].bounds.size.height-248)];
    [self.tableView.layer setCornerRadius:3.0];
    [self.tableView setClipsToBounds:YES];
    self.tableView.layer.borderColor = [UIColor colorWithHexString:@"cccccc"].CGColor;
    [self.tableView setSeparatorColor:[UIColor colorWithHexString:@"cccccc"]];
    self.tableView.layer.borderWidth = 1;
//	self.noContentView = [[CDINoTasksView alloc] initWithFrame:CGRectZero];
    
    self.headerView = [[IPIPageTableViewHeader alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
    [self.headerView setDelegate:self];
    [self.view addSubview:self.headerView];
    
    self.tabButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.tabButton.frame = CGRectMake(320, 83+150, 45, 51);
    [self.tabButton setImage:[UIImage imageNamed:@"rank_tab"] forState:UIControlStateNormal];
    [self.tabButton addTarget:self action:@selector(tabSelected) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.tabButton];
    
    self.rankBar = [[IPIRankBar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 50 - 44 - 20, 320, 50)];
    [self.rankBar setDelegate:self];
    [self.view addSubview:self.rankBar];
    
    [self.view setBackgroundColor:[UIColor standardBackgroundColor]];
    [self setSortUser:self.sortUser];
    [self setPage:self.page];
}

//these aren't being called in the segment container
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self setEditing:YES animated:YES];
    [SSRateLimit executeBlock:[self refresh] name:@"refresh-add-to-pages" limit:0.0];
    [self.tableView.pullToRefreshView triggerRefresh];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
//    [self.headerView setPage:self.page];
    [UIView animateWithDuration:0.2 animations:^{
        self.tabButton.frame = CGRectMake(276, 83+150, 45, 51);
    }];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

-(void)tabSelected{
    if ([self.page.is_collaborator boolValue] || [self.page.owner.remoteID isEqualToNumber:[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID]) {
        IPIPageRankActionViewController * pageRankActionViewController = [[IPIPageRankActionViewController alloc] init];
        [pageRankActionViewController setPage:self.page];
        [((UIViewController*)self.delegate).navigationController pushViewController:pageRankActionViewController animated:YES];
    }else{
        NSArray * teamMemberships;
        if (self.sortUser) {
            teamMemberships = [[[IPKTeamMembership MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"owner_id == %@ && team_id == %@", self.sortUser.remoteID, self.page.remoteID] inContext:[NSManagedObjectContext MR_contextForCurrentThread]] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:NO]]] mutableArrayValueForKey:@"position"];
        }else{
            teamMemberships = [[[IPKTeamMembership MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"pollaverage == YES && team_id == %@", self.page.remoteID] inContext:[NSManagedObjectContext MR_contextForCurrentThread]] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:NO]]] mutableArrayValueForKey:@"position"];
        }
        SSHUDView * hud = [[SSHUDView alloc] initWithTitle:@"Submitting page order." loading:YES];
        [hud show];
        
        [[IPKHTTPClient sharedClient] createCollaboratorRankingForPageWithId:[self.page.remoteID stringValue] userId:[self.sortUser.remoteID stringValue] newOrder:teamMemberships success:^(AFJSONRequestOperation *operation, id responseObject) {
            if ([responseObject objectForKey:@"errors"]) {
                NSLog(@"%@", responseObject);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.ignoreChange = NO;
                self.fetchedResultsController = nil;
                [self.tableView reloadData];
                self.loading = NO;
                [hud completeAndDismissWithTitle:@"Page reordered."];
                IPIPageRankActionViewController * pageRankActionViewController = [[IPIPageRankActionViewController alloc] init];
                [pageRankActionViewController setPage:self.page];
                [((UIViewController*)self.delegate).navigationController pushViewController:pageRankActionViewController animated:YES];
            });
        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                SSHUDView * hud = [[SSHUDView alloc] initWithTitle:@"Reorder failed."];
                [hud show];
                [hud failAndDismissWithTitle:@"Reorder failed."];
                [SSRateLimit resetLimitForName:[NSString stringWithFormat:@"refresh-list-%@", self.page.remoteID]];
                self.loading = NO;
            });
        }];
    }
}

#pragma mark - SSManagedViewController

+ (Class)fetchedResultsControllerClass {
	return [NSFetchedResultsController class];
}


- (Class)entityClass {
	return [IPKTeamMembership class];
}


- (NSPredicate *)predicate {
    if (self.sortUser != nil) {
        return [NSPredicate predicateWithFormat:@"team_id == %@ && owner_id == %@", self.page.remoteID, self.sortUser.remoteID];
    }else{
        return [NSPredicate predicateWithFormat:@"team_id == %@ && pollaverage == 1", self.page.remoteID];
    }
}

- (NSArray *)sortDescriptors{
    return @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
}

#pragma mark - IPICollaboratorRankingsDelegate

-(void)didSelectUser:(IPKUser*)sortUser{
    [self setSortUser:sortUser];
}


#pragma mark - SSManagedTableViewController

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	IPIProviderRankTableViewCell *providerCell = (IPIProviderRankTableViewCell *)cell;
	providerCell.provider = ((IPKTeamMembership*)[self objectForViewIndexPath:indexPath]).listing;
    providerCell.rankNumberLabel.text = [NSString stringWithFormat:@"%@",((IPKTeamMembership*)[self objectForViewIndexPath:indexPath]).position];
}


#pragma mark - CDIManagedTableViewController

- (void)editRow:(UITapGestureRecognizer *)editingTapGestureRecognizer {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)editingTapGestureRecognizer.view];
	if (!indexPath) {
		return;
	}
//
//	CDIRenameTaskViewController *viewController = [[CDIRenameTaskViewController alloc] init];
//	viewController.task = [self objectForViewIndexPath:indexPath];
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
//	navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
//	[self.navigationController presentModalViewController:navigationController animated:YES];
}


//- (void)coverViewTapped:(id)sender {
//	[self.addTaskView.textField resignFirstResponder];
//}


#pragma mark - Actions

- (void (^)(void))refresh {
    return ^(void){
        if (self.page == nil || self.loading) {
            return;
        }
        
        if (self.page.owner.name == nil) {
            self.loading = YES;

            [self.page.owner updateWithSuccess:^(void){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.loading = NO;
                });
            } failure:^(AFJSONRequestOperation *operation, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SSRateLimit resetLimitForName:[NSString stringWithFormat:@"refresh-list-%@", self.page.remoteID]];
                    self.loading = NO;
                });
            }];
        }
        
        self.loading = YES;

        NSString * pageIDString = [NSString stringWithFormat:@"%@", self.page.remoteID];
        IPKUser * sortUser = self.sortUser ? self.sortUser : nil;
        self.ignoreChange = YES;
        [[IPKHTTPClient sharedClient] getProvidersForPageWithId:pageIDString sortUser:sortUser success:^(AFJSONRequestOperation *operation, id responseObject) {
            if ([responseObject objectForKey:@"errors"]) {
                NSLog(@"%@", responseObject);
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                self.ignoreChange = NO;
                self.fetchedResultsController = nil;
                [self.tableView reloadData];
                self.loading = NO;
            });
        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString * errorDescription = [[[error localizedRecoverySuggestion] stringByReplacingOccurrencesOfString:@"{\"message\":\"" withString:@""] stringByReplacingOccurrencesOfString:@"\"}" withString:@""];
                if (errorDescription) {
                    SSHUDView * hud = [[SSHUDView alloc] initWithTitle:errorDescription];
                    [hud show];
                    [hud failAndDismissWithTitle:errorDescription];
                }else{
                    SSHUDView * hud = [[SSHUDView alloc] initWithTitle:@"Can't Access Page"];
                    [hud show];
                    [hud failAndDismissWithTitle:@"Can't Access Page"];
                }

                [SSRateLimit resetLimitForName:[NSString stringWithFormat:@"refresh-list-%@", self.page.remoteID]];
                self.loading = NO;
            });
        }];
    };
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[super controllerWillChangeContent:controller];
}

#pragma mark - Private

- (void)updateTableViewOffsets {
//	CGFloat offset = self.tableView.contentOffset.y;
//	CGFloat top = [CDIAddTaskView height] - fminf(0.0f, offset);
//	CGFloat bottom = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? self.keyboardRect.size.height : 0.0f;
//	self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(top, 0.0f, bottom, 0.0f);
//	self.pullToRefreshView.defaultContentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottom, 0.0f);
//	self.addTaskView.shadowView.alpha = fmaxf(0.0f, fminf(offset / 24.0f, 1.0f));
}


- (void)_renameList:(id)sender {
//	CDICreateListViewController *viewController = [[CDICreateListViewController alloc] init];
//	viewController.list = self.list;
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
//	navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
//	[self.navigationController presentModalViewController:navigationController animated:YES];
}


- (void)_archiveTasks:(id)sender {
	// TODO: This is super ugly
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Archive Completed", @"Archive All", nil];
		[actionSheet showFromRect:[sender frame] inView:self.view animated:YES];
	} else {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Archive Completed", @"Archive All", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		[actionSheet showInView:self.navigationController.view];
	}
}


- (void)_archiveAllTasks:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Archive All Tasks" message:@"Do you want to archive all of the tasks in this list?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Archive", nil];
	alert.tag = 1;
	[alert show];
}


- (void)_archiveCompletedTasks:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Archive Completed Tasks" message:@"Do you want to archive all of the completed tasks in this list?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Archive", nil];
	alert.tag = 2;
	[alert show];
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *const cellIdentifier = @"cellIdentifier";
	
	IPIProviderRankTableViewCell *cell = (IPIProviderRankTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[IPIProviderRankTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.editing = NO;
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//	return self.addTaskView;
//}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IPKProvider * provider = ((IPKTeamMembership*)[self objectForViewIndexPath:indexPath]).listing;
    [self.delegate didSelectProvider:provider];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle != UITableViewCellEditingStyleDelete) {
		return;
	}
}
// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath;{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}
// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	if (sourceIndexPath.row == destinationIndexPath.row) {
		return;
	}
	
	self.ignoreChange = NO;
//	NSMutableArray *tasks = [self.fetchedResultsController.fetchedObjects mutableCopy];
//	CDKTask *task = [self objectForViewIndexPath:sourceIndexPath];
//	[tasks removeObject:task];
//	[tasks insertObject:task atIndex:destinationIndexPath.row];
//	
//	NSInteger i = 0;
//	for (task in tasks) {
//		task.position = [NSNumber numberWithInteger:i++];
//	}
//	
//	[self.managedObjectContext save:nil];
//	self.ignoreChange = NO;
//	
//	[CDKTask sortWithObjects:tasks];
}


//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//	return [CDIAddTaskView height];
//}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	CDKTask *task = [self objectForViewIndexPath:indexPath];
//	CGFloat offset = self.editing ? 29.0f : 0.0f;
//	return [CDITaskTableViewCell cellHeightForTask:task width:tableView.frame.size.width - offset];
//	return [CDITaskTableViewCell cellHeightForTask:task width:tableView.frame.size.width];
//}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    prevContentOffset = scrollView.contentOffset.y;
//    [_fullScreenDelegate scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (prevContentOffset < scrollView.contentOffset.y) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect rankFrame = self.rankBar.frame;
        rankFrame.origin.y = [UIScreen mainScreen].bounds.size.height;
        self.rankBar.frame = rankFrame;
        [UIView commitAnimations];
    }else{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect rankFrame = self.rankBar.frame;
        rankFrame.origin.y = [UIScreen mainScreen].bounds.size.height - rankFrame.size.height - 44 - 20;
        self.rankBar.frame = rankFrame;
        [UIView commitAnimations];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    LOG_INT(self.tableView.tracking);
    //    LOG_INT(self.tableView.dragging);
    //    LOG_INT(self.tableView.decelerating);
    
//    [_fullScreenDelegate scrollViewDidScroll:scrollView];
    

}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
//    [_fullScreenDelegate scrollViewDidScrollToTop:scrollView];
}

#pragma mark - IPIRankBarDelegate

-(void)didSelectRankingSwitch{
    IPICollaboratorRankingsViewController * collaboratorRankingsViewController = [[IPICollaboratorRankingsViewController alloc] init];
    [collaboratorRankingsViewController setPage:self.page];
    [collaboratorRankingsViewController setDelegate:self];
    UINavigationController * collabNavController = [[UINavigationController alloc] initWithRootViewController:collaboratorRankingsViewController];
    [(UIViewController*)self.delegate presentModalViewController:collabNavController animated:YES];
}

#pragma mark - TTTAttributedLabelDelegate

//- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
//	// Open tag
//	if ([url.scheme isEqualToString:@"x-cheddar-tag"]) {
//		CDKTag *tag = [CDKTag existingTagWithName:url.host];
//		self.currentTag = tag;
//		return;
//	}
//	
//	// Open browser
//	if ([url.scheme.lowercaseString isEqualToString:@"http"] || [url.scheme.lowercaseString isEqualToString:@"https"]) {
//		CDIWebViewController *viewController = [[CDIWebViewController alloc] init];
//		[viewController loadURL:url];
//		
//		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
//			[self.splitViewController presentModalViewController:navigationController animated:YES];
//		} else {
//			[self.navigationController pushViewController:viewController animated:YES];
//		}
//		return;
//	}
//	
//	// Open other URLs
//	[[UIApplication sharedApplication] openURL:url];
//}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
//	if (buttonIndex == 0) {
//		[self setEditing:NO animated:YES];
//		[self.list archiveCompletedTasks];
//	} else if (buttonIndex == 1) {
//		[self setEditing:NO animated:YES];
//		[self.list archiveAllTasks];
//	}
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//	if (buttonIndex == 0) {
//		return;
//	}
//
//	[self setEditing:NO animated:YES];
//	
//	if (alertView.tag == 1) {
//		[self.list archiveAllTasks];
//		[self setEditing:NO animated:YES];
//	} else if (alertView.tag == 2) {
//		[self.list archiveCompletedTasks];
//	}
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//	CDKTask *task = [self objectForViewIndexPath:self.editingIndexPath];
//	task.text = textField.text;
//	task.displayText = textField.text;
//	task.entities = nil;
//	[task save];
//	[task update];
//	
//	[self endCellTextEditing];
	return NO;
}


#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context != (__bridge void *)self) {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
		return;
	}

	if ([keyPath isEqualToString:@"title"]) {
		self.title = [change objectForKey:NSKeyValueChangeNewKey];
	} else if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad && [keyPath isEqualToString:@"archivedAt"]) {
		if ([change objectForKey:NSKeyValueChangeNewKey] != [NSNull null]) {
			[self.navigationController popToRootViewControllerAnimated:YES];
		}
	}
    if ([keyPath isEqualToString:@"owner"] || [keyPath isEqualToString:@"is_favorite"] || [keyPath isEqualToString:@"is_following"]) {
    }
    if ([keyPath isEqualToString:@"name"]) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.headerView setPage:_page];
        });
    }
}

#pragma mark - IPIPageTableViewHeaderDelegate

-(void)followButtonPressed:(IPKPage*)page{
    NSString * pageId = [NSString stringWithFormat:@"%@", page.remoteID];
    if ([page.is_following boolValue]) {
        [[IPKHTTPClient sharedClient] unfollowPageWithId:pageId success:^(AFJSONRequestOperation *operation, id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loading = NO;
                [self setManagedObject:[IPKPage objectWithRemoteID:page.remoteID]];
            });
        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SSRateLimit resetLimitForName:[NSString stringWithFormat:@"refresh-list-%@", self.page.remoteID]];
                self.loading = NO;
            });
        }];
    } else {
        [[IPKHTTPClient sharedClient] followPageWithId:pageId success:^(AFJSONRequestOperation *operation, id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loading = NO;
                [self setManagedObject:[IPKPage objectWithRemoteID:page.remoteID]];
            });
        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SSRateLimit resetLimitForName:[NSString stringWithFormat:@"refresh-list-%@", self.page.remoteID]];
                self.loading = NO;
            });
        }];
    }
}

-(void)favoriteButtonPressed:(IPKPage*)page{
    NSString * pageId = [NSString stringWithFormat:@"%@", page.remoteID];
    if ([page.is_favorite boolValue]) {
        [[IPKHTTPClient sharedClient] unfavoritePageWithId:pageId success:^(AFJSONRequestOperation *operation, id responseObject) {
            NSLog(@"%@", page);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loading = NO;
                [self setManagedObject:[IPKPage objectWithRemoteID:page.remoteID]];
            });
        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SSRateLimit resetLimitForName:[NSString stringWithFormat:@"refresh-list-%@", self.page.remoteID]];
                self.loading = NO;
            });
        }];
    }else{
        [[IPKHTTPClient sharedClient] favoritePageWithId:pageId success:^(AFJSONRequestOperation *operation, id responseObject) {
            NSLog(@"%@", page);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loading = NO;
                [self setManagedObject:[IPKPage objectWithRemoteID:page.remoteID]];
            });
        } failure:^(AFJSONRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SSRateLimit resetLimitForName:[NSString stringWithFormat:@"refresh-list-%@", self.page.remoteID]];
                self.loading = NO;
            });
        }];
    }
}

-(void)shareButtonPressed:(IPKPage*)page{
    [IPISocialShareHelper tweetPage:page fromViewController:self];
}

@end
