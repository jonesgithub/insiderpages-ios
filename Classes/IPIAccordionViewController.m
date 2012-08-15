//
//  IPIAccordionViewController.m
//  InsiderPages for iOS
//
//  Created by Truman, Christopher on 8/14/12.
//  Copyright (c) 2012 InisderPages. All rights reserved.
//

#import "IPIAccordionViewController.h"
#import "IPIExpandingPageHeaderTableViewCell.h"

@interface IPIAccordionViewController ()

@property (nonatomic, retain) UISearchBar * searchBar;

@end

@implementation IPIAccordionViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.accordionView = [[AccordionView alloc] initWithFrame:CGRectMake(0, 44, 320, 416)];
        self.page1 = [[IPIAccordionPagesViewController alloc] initWithSectionHeader:@"Mine"];
        self.page2 = [[IPIAccordionPagesViewController alloc] initWithSectionHeader:@"Following"];
        self.page3 = [[IPIAccordionPagesViewController alloc] initWithSectionHeader:@"Favorite"];
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];
        self.searchBar.delegate = self;
        [[self view] addSubview:self.searchBar];

        UIButton *header1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
        [header1 setTitle:@"Mine" forState:UIControlStateNormal];
//        IPIExpandingPageHeaderTableViewCell * pageHeader1 = [[IPIExpandingPageHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sectionIdentifier"];
        UIButton *header2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
        [header2 setTitle:@"Following" forState:UIControlStateNormal];
//        IPIExpandingPageHeaderTableViewCell * pageHeader2 = [[IPIExpandingPageHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sectionIdentifier"];
        UIButton *header3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
        [header3 setTitle:@"Favorite" forState:UIControlStateNormal];
//        IPIExpandingPageHeaderTableViewCell * pageHeader3 = [[IPIExpandingPageHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sectionIdentifier"];
        
        [self.accordionView addHeader:header1 withView:self.page1.view];
        [self.accordionView addHeader:header2 withView:self.page2.view];
        [self.accordionView addHeader:header3 withView:self.page3.view];
        [self.accordionView setDelegate:self];
        [self.accordionView setSelectedIndex:0];
        [[self view] addSubview:self.accordionView];
        [self.accordionView setNeedsLayout];

    }
    return self;
}

- (void)accordion:(AccordionView *)accordion didChangeSelection:(NSIndexSet *)selection{
    switch ([accordion selectedIndex]) {
        case 0:
            [self.page1 refresh:nil];
            self.page1.fetchedResultsController = nil;
            break;
        case 1:
            [self.page2 refresh:nil];
            self.page2.fetchedResultsController = nil;
            break;
        case 2:
            [self.page3 refresh:nil];
            self.page3.fetchedResultsController = nil;
            break;
            
        default:
            [self.page1 refresh:nil];
            self.page1.fetchedResultsController = nil;
            [self.page2 refresh:nil];
            self.page2.fetchedResultsController = nil;
            [self.page3 refresh:nil];
            self.page3.fetchedResultsController = nil;
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UISearchBarDelegate 

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{return YES;}                      // return NO to not become first responder
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{}                     // called when text starts editing
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{return YES;}                        // return NO to not resign first responder
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{}                       // called when text ends editing
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{}   // called when text changes (including clear)
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0){return YES;} // called before text changes

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{[searchBar resignFirstResponder];}                     // called when keyboard search button pressed
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar{}                   // called when bookmark button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{}                    // called when cancel button pressed
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar NS_AVAILABLE_IOS(3_2){} // called when search results button pressed

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope NS_AVAILABLE_IOS(3_0){}

@end