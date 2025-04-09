---
layout: project
title: jGrade2
caption: An updated grader for CS teachers.
description: >
  An updated plugin for Gradescope users to grade Java submissions like a pro. Updated now for Java 21 and JUnit5 with easy Maven integration.
date: 2024-10-13
image: 
  path: /assets/img/projects/jgrade2-cover.png
links:
  - title: Github Repo
    url: https://github.com/jgrade2/jgrade2
---

# JGrade2

## I (kinda) don't like Java

As a daily driver, I am not a fan of the Java language. It's verbose and clunky syntax is reminiscent of the old days where programming was more about creating the code-space than playing in it. As someone who starts a new project every other weak, Java's framework setup eats into those precious few days. However, I do think Java has its place. Its accessibility and standardization makes it a well-suited choice for large, legacy-focused systems. Its verbosity is a feature, not a bug- in some cases- and is excellent for "fine-grained control" over a system. Thus, while I discourage programmers from using Java, I heavily encourage [computer science students]({% post_url 2025-01-17-computer-sciencer-vs-programmer %}) to master it.

All that is to say, when a professor and colleague came to me for help on this project, I was more than happy to oblige. Not only was it a chance for eliminating more tediousness in this world, I will never say no to scoring some brownie points with a colleague. 

## Outdated-ness

This project is less so about the intricacies in Java auto-graders and more about awareness to not only this tool, but also the need for versioning, dependency checks, and long-term support. Here's the issue: A legacy-coding class utilizes [JUnit](https://junit.org/) for auto-grading assignments. From unit tests to end-to-end intergration checks, this class, and the university, partners with [Gradescope](https://www.gradescope.com/) for managing student submissions. (There is also test coverage and mutation testing in the works, but that is a different story.) Origionally written in 2019, [@tkutcher](https://github.com/tkutcher) wrote the first [JGrade](https://github.com/tkutcher/jgrade) to compile *Junit*'s (v4) output to *Gradescope* specification. However, as time moved on from the pandemic, so did *Junit* and it upgraded to version 5, completely breaking *JGrade*. While not really a problem if the class locked the version of *Junit* to v4, they were also updating to Java 21, which was not compatible with *Junit4*. Stuck between a rock and a hard place, the class implemented a workaround for the time being (i.e., the computing power of the TAs).

## Enter jGrade2

I will be completely honest, this project was really more a 2 week exercise of entering and updating a legacy codebase, ironically mirroring the concepts taught in the class this was origionally for. Immersing myself into the codebase was really easy thanks to *@tkutcher*'s excellent demostration of code organization (thank you Tim!). A glace at the changelog from *Junit4* to 5 brought me about 90% of the way there with understanding which methods to update. The other 10% was a matter of understanding the stack trace and creating some test cases to verify sanity. All in all, the main issue came from a rewrite of how *Junit5* exposed its test discovery, progress, and results. Since this post won't be complete without some code, here is a snippet of the rewrite:

~~~java
// file: `src/main/java/com/github/jgrade2/jgrade2/Grader.java`

public void runJUnitGradedTests(Class<test> testSuite) {
  LauncherDiscoveryRequest request = LauncherDiscoveryRequestBuilder.request()
                                    .selectors(selectClass(testSuite))
                                    .build();

  GradedTestListener listener = new GradedTestListener();

  LauncherSession session = LauncherFactory.openSession();
  Launcher launcher = session.getLauncher();
  launcher.registerTestExecutionListeners(listener);
  TestPlan testPlan = launcher.discover(request);
  launcher.execute(testPlan);
...
~~~

## Conclusion

And that was pretty much it! The rest of the time was spent creating a new Github organization to host the update in, give proper credit to *@tkutcher*, rewritting the examples, establishing a CD/CI pipeline, and registering it onto [Maven Central](https://central.sonatype.com/artifact/io.github.jgrade2/jgrade2) for easy use! Please feel free to check it and out and implement it into your classroom workflow. It's usage is the exact same as the origional *JGrade*, with a new depencency import if you are using Maven. If you're too lazy to check out the repo, you can add it to your project with the following addition to your `pom.xml`:

~~~xml
<dependency>
  <groupId>io.github.jgrade2</groupId>
  <artifactId>jgrade2</artifactId>
  <version>${jGrade2.version}</version>
</dependency>
~~~

Thanks for reading this short project! I hope you're able to get some use out of this new plugin!