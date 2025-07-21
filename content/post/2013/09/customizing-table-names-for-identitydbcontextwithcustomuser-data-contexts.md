---
title: "Customizing table names for IdentityDbContextWithCustomUser data contexts"
date: "2013-09-23T18:53:11.0000000"
author: "Mike Goatly"
---
I was playing around with Visual Studio 2013 and Entity Framework 6 in an MVC 5 application recently\, and was impressed with the level of support that is provided out of the box for oAuth\. If you create a new ASP\.NET MVC 5 site with the Individual User Accounts authentication option and follow all the [instructions on MSDN](http://go.microsoft.com/fwlink/?LinkId=301864)\, it's trivial getting at least Google authentication working against a new site\.  

If you follow the instructions through to the end\, you’ll end up having a data context that derives from IdentityDbContextWithCustomUser<TUser>\, where TUser is your custom user entity that derives from \[NAMESPACE\]User\.  

If you just run this code as\-is and examine the database\, you'll see the following tables: 

```
dbo.AspNetRoles 
dbo.AspNetTokens 
dbo.AspNetUserClaims 
dbo.AspNetUserLogins 
dbo.AspNetUserManagement 
dbo.AspNetUserRoles 
dbo.AspNetUsers 
dbo.AspNetUserSecrets
```
Fantastic\, but what if you want the tables to be named differently\, or exist in a separate database schema? My first thought was have my data context implement the base class of IdentityDbContextWithCustomUser\, IdentityDbContext<TUser\, TUserClaim\, TUserSecret\, TUserLogin\, TRole\, TUserRole\, TToken\, TUserManagement> \(that's a lot of generic parameters there…\) and provide custom implementations of each of the various generic parameters\, conforming to any interface constraints\, e\.g\. IUser\, IUserManagement\. That way I could change the entity shapes to suit me a bit better\. 

Unfortunately this approach failed \- there seemed to be some logic buried deep that was still taking dependencies on the old concrete types\, rather than the ones I had specified in the generic constraints\. \(As an aside\, this is RC1\, so your mileage may vary in the release candidate when it's released\) 

It turns out that instead of reinventing the wheel \(re\-creating all the model classes\)\, the easiest thing to do is decorate the existing wheel to suit your tastes\. \(Metaphor over\, code follows:\) 

``` csharp
public class MyDataContext : IdentityDbContextWithCustomUser<Member>
{
    protected override void OnModelCreating(DbModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>()
            .ToTable("Member", "Security")
            .Property(p => p.Id).HasColumnName("MemberId");

        modelBuilder.Entity<Member>()
            .ToTable("Member", "Security")
            .Property(p => p.Id).HasColumnName("MemberId");

        modelBuilder.Entity<Role>()
            .ToTable("Role", "Security")
            .Property(p => p.Id).HasColumnName("RoleId");

        modelBuilder.Entity<Token>()
            .ToTable("Token", "Security")
            .Property(p => p.Id).HasColumnName("TokenId");

        modelBuilder.Entity<UserClaim>()
            .ToTable("MemberClaim", "Security")
            .Property(p => p.UserId).HasColumnName("MemberId");

        modelBuilder.Entity<UserLogin>()
            .ToTable("MemberLogin", "Security")
            .Property(p => p.UserId).HasColumnName("MemberId");

        modelBuilder.Entity<UserManagement>()
            .ToTable("MemberManagement", "Security")
            .Property(p => p.UserId).HasColumnName("MemberId");

        modelBuilder.Entity<UserRole>()
            .ToTable("MemberRole", "Security")
            .Property(p => p.UserId).HasColumnName("MemberId");

        modelBuilder.Entity<UserSecret>()
            .ToTable("MemberSecret", "Security");

        base.OnModelCreating(modelBuilder);
    }
}
```
Here the existing model code from the Microsoft\.AspNet\.Identity\.EntityFramework namespace is just re\-mapped to alternative table and column names\. Using the above code results in the following tables being created: 

```
Security.Member
Security.MemberClaim
Security.MemberLogin
Security.MemberManagement
Security.MemberRole
Security.MemberSecret
Security.Role
Security.Token
```
Hope that helps\! 

