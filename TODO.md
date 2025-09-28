# TODO: Fix Routing for Organization Officer and Admin Authorization

## Completed Steps:
- [x] Analyzed the code to identify the routing issue
- [x] Updated OfficerAuthorizationScreen to navigate to BaseOfficerDashboard instead of '/home'
- [x] Updated AdminAuthorizationScreen to navigate to AdminDashboard instead of '/home'
- [x] Added necessary imports for BaseOfficerDashboard and AdminDashboard

## Remaining Steps:
- [ ] Test the changes to verify correct routing
  - [ ] Test officer authentication and routing to organization-specific dashboard
  - [ ] Test admin authentication and routing to admin dashboard
  - [ ] Verify that the generic HomeScreen is no longer used for these roles

## Summary:
The routing issue has been fixed by updating the authorization screens to navigate directly to their respective dashboards after successful authentication. Officers will now go to their organization-specific dashboard, and admins will go to the admin dashboard.
