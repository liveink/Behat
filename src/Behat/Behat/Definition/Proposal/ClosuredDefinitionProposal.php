<?php

namespace Behat\Behat\Definition\Proposal;

use Behat\Gherkin\Node\StepNode;

use Behat\Behat\Context\ContextInterface,
    Behat\Behat\Context\ClosuredContextInterface;

/*
 * This file is part of the Behat.
 * (c) Konstantin Kudryashov <ever.zet@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/**
 * Closured definitions proposal.
 *
 * @author      Konstantin Kudryashov <ever.zet@gmail.com>
 */
class ClosuredDefinitionProposal implements DefinitionProposalInterface
{
    /**
     * @see     Behat\Behat\Definition\Proposal\DefinitionProposalInterface::supports()
     */
    public function supports(ContextInterface $context)
    {
        return $context instanceof ClosuredContextInterface;
    }

    /**
     * @see     Behat\Behat\Definition\Proposal\DefinitionProposalInterface::propose()
     */
    public function propose(StepNode $step)
    {
        $text = $step->getText();

        $regex = preg_replace('/([\[\]\(\)\\\^\$\.\|\?\*\+])/', '\\\\$1', $text);
        $regex = preg_replace(
            array(
                '/\'([^\']*)\'/', '/\"([^\"]*)\"/', // Quoted strings
                '/(\d+)/',                          // Numbers
            ),
            array(
                "\'([^\']*)\'", "\"([^\"]*)\"",
                "(\\d+)",
            ),
            $regex, -1, $count
        );
        $regex = preg_replace('/\'.*(?<!\')/', '\\\\$0', $regex); // Single quotes without matching pair (escape in resulting regex)

        $args = array("\$world");
        for ($i = 0; $i < $count; $i++) {
            $args[] = "\$arg".($i + 1);
        }

        foreach ($step->getArguments() as $argument) {
            if ($argument instanceof PyStringNode) {
                $args[] = "\$string";
            } elseif ($argument instanceof TableNode) {
                $args[] = "\$table";
            }
        }

        $description = sprintf(<<<PHP
\$steps->%s('/^%s$/', function(%s) {
    throw new \Behat\Behat\Exception\Pending();
});
PHP
          , '%s', $regex, implode(', ', $args)
        );

        return array(
            md5($description) => sprintf($description, str_replace(' ', '_', $step->getType()))
        );
    }
}