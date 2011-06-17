Feature: I18n
  In order to write i18nal features
  As a feature writer
  I need to have i18n support

  Background:
    Given a file named "features/bootstrap/bootstrap.php" with:
      """
      <?php
      require_once 'PHPUnit/Autoload.php';
      require_once 'PHPUnit/Framework/Assert/Functions.php';
      """
    And a file named "features/bootstrap/FeaturesContext.php" with:
      """
      <?php

      use Behat\Behat\Context\BehatContext, Behat\Behat\Exception\Pending;
      use Behat\Gherkin\Node\PyStringNode,  Behat\Gherkin\Node\TableNode;

      class FeaturesContext extends BehatContext implements Behat\Behat\Context\AnnotatedContextInterface
      {
          private $value = 0;

          /**
           * @Given /Я ввел (\d+)/
           */
          public function iHaveEntered($number) {
              $this->value = intval($number);
          }

          /**
           * @Then /Я должен иметь (\d+)/
           */
          public function iShouldHave($number) {
              assertEquals(intval($number), $this->value);
          }

          /**
           * @When /Я добавлю (\d+)/
           */
          public function iAdd($number) {
              $this->value += intval($number);
          }

          /**
           * @When /^Что-то еще не сделано$/
           */
          public function somethingNotDone() {
              throw new Pending();
          }
      }
      """
    And a file named "features/World.feature" with:
      """
      # language: ru
      Функционал: Постоянство мира
        Чтобы поддерживать стабильными тесты
        Как разработчик функционала
        Я хочу чтобы Мир сбрасывался между сценариями

        Предыстория:
          Если Я ввел 10

        Сценарий: Неопределен
          То Я должен иметь 10
          И Что-то новое
          То Я должен иметь 10

        Сценарий: В ожидании
          То Я должен иметь 10
          И Что-то еще не сделано
          То Я должен иметь 10

        Сценарий: Провален
          Если Я добавлю 4
          То Я должен иметь 13

        Структура сценария: Пройдено и Провалено
          Допустим Я должен иметь 10
          Если Я добавлю <значение>
          То Я должен иметь <результат>

          Значения:
            | значение | результат |
            |  5       | 16        |
            |  10      | 20        |
            |  23      | 32        |
      """

  Scenario: Pretty
    When I run "behat -f pretty --lang=ru"
    Then it should fail with:
      """
      Функционал: Постоянство мира
        Чтобы поддерживать стабильными тесты
        Как разработчик функционала
        Я хочу чтобы Мир сбрасывался между сценариями
      
        Предыстория:     # features/World.feature:7
          Если Я ввел 10 # FeaturesContext::iHaveEntered()
      
        Сценарий: Неопределен  # features/World.feature:10
          То Я должен иметь 10 # FeaturesContext::iShouldHave()
          И Что-то новое
          То Я должен иметь 10 # FeaturesContext::iShouldHave()
      
        Сценарий: В ожидании      # features/World.feature:15
          То Я должен иметь 10    # FeaturesContext::iShouldHave()
          И Что-то еще не сделано # FeaturesContext::somethingNotDone()
            TODO: write pending definition
          То Я должен иметь 10    # FeaturesContext::iShouldHave()
      
        Сценарий: Провален        # features/World.feature:20
          Если Я добавлю 4        # FeaturesContext::iAdd()
          То Я должен иметь 13    # FeaturesContext::iShouldHave()
            Failed asserting that <integer:14> is equal to <integer:13>.
      
        Структура сценария: Пройдено и Провалено # features/World.feature:24
          Допустим Я должен иметь 10             # FeaturesContext::iShouldHave()
          Если Я добавлю <значение>              # FeaturesContext::iAdd()
          То Я должен иметь <результат>          # FeaturesContext::iShouldHave()
      
          Значения:
            | значение | результат |
            | 5        | 16        |
              Failed asserting that <integer:15> is equal to <integer:16>.
            | 10       | 20        |
            | 23       | 32        |
              Failed asserting that <integer:33> is equal to <integer:32>.
      
      6 сценариев (1 пройден, 1 в ожидании, 1 не определен, 3 провалено)
      23 шага (16 пройдено, 2 пропущено, 1 в ожидании, 1 не определен, 3 провалено)
      
      Вы можете реализовать определения для новых шагов с помощью этих шаблонов:
      
          /**
           * @Given /^Что-то новое$/
           */
          public function stepDefinition1()
          {
              throw new Pending();
          }
      """

  Scenario: Progress
    When I run "behat -f progress --lang=ru"
    Then it should fail with:
      """
      ..U-..P-..F...F.......F
      
      (::) проваленные шаги (::)
      
      01. Failed asserting that <integer:14> is equal to <integer:13>.
          In step `То Я должен иметь 13'. # FeaturesContext::iShouldHave()
          From scenario `Провален'.       # features/World.feature:20
      
      02. Failed asserting that <integer:15> is equal to <integer:16>.
          In step `То Я должен иметь 32'.       # FeaturesContext::iShouldHave()
          From scenario `Пройдено и Провалено'. # features/World.feature:24
      
      03. Failed asserting that <integer:33> is equal to <integer:32>.
          In step `То Я должен иметь 32'.       # FeaturesContext::iShouldHave()
          From scenario `Пройдено и Провалено'. # features/World.feature:24
      
      (::) шаги в ожидании (::)
      
      01. TODO: write pending definition
          In step `И Что-то еще не сделано'.    # FeaturesContext::somethingNotDone()
          From scenario `В ожидании'.           # features/World.feature:15
      
      6 сценариев (1 пройден, 1 в ожидании, 1 не определен, 3 провалено)
      23 шага (16 пройдено, 2 пропущено, 1 в ожидании, 1 не определен, 3 провалено)
      
      Вы можете реализовать определения для новых шагов с помощью этих шаблонов:
      
          /**
           * @Given /^Что-то новое$/
           */
          public function stepDefinition1()
          {
              throw new Pending();
          }
      """