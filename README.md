# Template Website [![CircleCI](https://circleci.com/gh/yoda-tech/public-website.svg?style=svg)](https://circleci.com/gh/yoda-tech/public-website)

This repo contains your public website.

As well as the website code, you have a fully working Continuous Integration (CI) pipeline (we use CircleCI).

## Pre-requisites

You need a Mac.

You need to [install](https://brew.sh/) `homebrew` on your Mac.

You need to have `git` installed (`brew install git`).

You need an AWS account (free tier should be fine for normal loads).

You need a CircleCI account and you need to have linked it to your GitHub Account.

### The AWS Certificate Shuffle

You need the ability in AWS to create ACM certs in the `us-east-1 (US Virginia)` region. If you created an AWS root account where the default region is not `us-east-1` then you need to contact Customer Services and request the ability to create certs in a non-default region (which MUST be `us-east-1` becasue CloudFront always looks for certs in this region).
Once you have the ability to create a cert in `us-east-1` you can check what certs have been created with:

```shell
aws acm list-certificates --certificate-statuses "ISSUED" --region us-east-1
```

A good workflow to test custom domains, is to:

- make sure you can create a cert in `us-east-1` via the AWS console to confirm the above.

- list the certs using `aws acm list-certificates --certificate-statuses "ISSUED" --region us-east-1`

- run `up stack plan`. If you recieve the follwing error:

```
An error of `LimitExceededException: Cannot request more certificates in this account. Contact Customer Service for details
```

then this can mean that you cannot create ACM certs in the `us-east-1` region.

- once `up stack plan` works without errors, run `up stack apply`

- if you can create a cert but it is not marked as `ISSUED` after an hour or so, make sure you have accepted the domain verification emails from AWS.

- certs marked as `PENDING_VALIDATION` will give the following error when you run `up stack apply`:

```shell
ApiDomainStaging: Unable to associate certificate arn:aws:acm:us-east-1:<cert id>:certificate/<cert hash> with CloudFront. This error may prevent the domain name stage-website.panopticon.tech from being used in API Gateway for up to 40 minutes. Please ensure the certificate domain name matches the requested domain name, and that this user has permission to call cloudfront:UpdateDistribution on '*' resources.
     DnsZone<yourdomain>: Resource creation cancelled
     ApiDomainProduction: Unable to associate certificate arn:aws:acm:us-east-1:<cert id>:certificate/<cert hash> with CloudFront. This error may prevent the domain name panopticon.tech from being used in API Gateway for up to 40 minutes. Please ensure the certificate domain name matches the requested domain name, and that this user has permission to call cloudfront:UpdateDistribution on '*' resources.
```

- once `up stack plan` runs without errors, then run `up stack apply` and you should be all set.

## Getting started

### Dependencies used by this repo

We use `hugo` to template the website.

We have our own hugo theme which you need to install (see below).

We use `up` to deploy the static site to AWS infrastructure. `up` takes the static site and auto configures/deploys to an AWS account (using API gateway -> lambda -> S3).

You will need to have a valid `~~/.aws/credentials` file that contains your AWS secrets, in order for `up` to work. We create this file for your on CircleCI (from your AWS credentials stored as env vars).

You should *NEVER* use the root AWS account. Create a 'machine user' account for the website and use this AWS user's credentials. A list of the AWS permissions needed for the machine user can be found [here](https://up.docs.apex.sh/#aws_credentials.iam_policy_for_up_cli).

### Steps to run locally

You will need clone this repo to your local machine. Currently, running on OSX (Mac) is the only supported platform.

You can clone the repo by copying the `git:` clone link on the top right of this page and then in a terminal, navigate to where you keep code on your laptop, then:

```shell
git clone <clone url>` where `clone url` is the contents of your copied clone link.
```

Then you should navigate into the repo with:

```shell
cd public-website`
```

Firstly, you need to make all the script files in this repo executable, so go to a terminal and run:

```shell
find . -name "*.sh" -maxdepth 1 -exec chmod +x {} \;
```

#### Install dependencies on OSX (available as `osx_install.sh`)

In a terminal, run: 

```shell
./osx_install.sh
```

This will install all the dependencies that you need so you can develop locally.

You need to fetch our website theme. To do this, open a terminal and run (in the root repo dir):

```shell
./fetch_theme.sh 0.0.1
```

This will install our theme into `website/themes/fylo`.

If a new version of the theme is released, then you can fetch it locally by running this script with the new version number.

If you want to update the version of the theme that is used in your stage or production website, then you will need to change the `THEME_VERSION` environment variable on your build.

#### Editing your website

- You should only need to edit `config.toml` and files in `static` or `layouts`.

- *DO NOT* edit any files in `themes/fylo`. Any changes you make to the theme will be lost if you install an update to the theme.

- We have added `layouts/partials/hero.html` and `static/js/main.js` as examples of files that override their equivalents in the `themes/fylo` directories. If you need to, you can add any further override files into the top level folders of your website.

- You can decide which sections are shown in the website by editing `config.toml`.

- You can decide how things should look by adding override files.

#### Developing on your local machine

You need to navigate into this repo `website` directory (assuming you are in `place/where/you/keep/code/public-website`):

```shell
cd website
```

From here you can start a local webserver:

```shell
hugo server -D
```

 This will start a webserver locally ( go [here](http://localhost:1313) ) and will watch for any changes to your files.

When you have made the changes you want, you can then commit the changes using `git` and push to your repo.

## CI

The CI pipeline is already configured:

- If you push changes to a `stage` branch, then your changes (if successful) will be automatically deployed to your `stage` environment.

- If you push a git tag that begins with `v.`, e.g. `v.0.1.3` the your changes (if successful) will be automatically pushed to your `production` environment.

- In all other cases, your changes will be built and tested, but not deployed.

### Steps to getting CI working

- Sign up for [CircleCI](https://circleci.com).

- Ensure you have all the mandatory env vars set (see below)

- Ensure you have allowed CircleCI to access this repo.

- Ensure you have created a Slack channel called `ci` and created a Slack webhook for it.

## Env vars

#### Needed for CI (all mandatory) - configure these on the CircleCI website.

- `AWS_ACCESS_KEY_ID` - your AWS access key

- `AWS_SECRET_ACCESS_KEY` - your AWS secret key

- `THEME_VERSION` - the version of the website theme to download

## Explanation of the directories and files.

### .circleci

This directory contains your CircleCI config file.

### website

This directory contains your website code.

### fetch_theme.sh

Run this script to fetch the theme for the website.
You must pass it the version of the theme that you want to install:

```shell
./fetch_theme.sh 0.0.1
```

### osx_install.sh

This file can be used if you are developing on OSX (Mac). Running this script will install all the things that you need to maintain your website.

To run the script, go to a terminal, navigate to this folder and then run:

```shell
./osx_install.sh
```

### test.sh

This file contains a simple smoke test to make sure your deployment works. You can run this locally, but it is also run on CI.

### up.json

This file contains your `up` config. This file is used to deploy your website to your AWS infrastructure.
