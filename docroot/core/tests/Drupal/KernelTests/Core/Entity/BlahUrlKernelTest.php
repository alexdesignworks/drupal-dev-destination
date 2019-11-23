<?php

namespace Drupal\KernelTests\Core\Entity;

use Drupal\entity_test\Entity\EntityTest;
use Drupal\KernelTests\KernelTestBase;
use Drupal\Tests\user\Traits\UserCreationTrait;

/**
 * Tests URL method.
 *
 * @group Entity
 */
class BlahUrlKernelTest extends KernelTestBase {

  use UserCreationTrait;

  /**
   * {@inheritdoc}
   */
  public static $modules = [
    'entity_test',
    'user',
  ];

  public function testUrl() {
    $this->installEntitySchema('entity_test');
    $this->installEntitySchema('user');

    $entity = EntityTest::create();
    $entity->save();
    $entityId = $entity->id();
    $url = \Drupal\Core\Url::fromUri('internal:/entity_test/' . $entityId);
  }

}
