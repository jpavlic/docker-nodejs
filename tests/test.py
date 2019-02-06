import os
import docker
import unittest
import logging
import sys
import random

from docker.errors import NotFound

# LOGGING #
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# Docker Client
client = docker.from_env()

NAMESPACE = os.environ.get('NAMESPACE')
VERSION = os.environ.get('VERSION')
USE_RANDOM_USER_ID = os.environ.get('USE_RANDOM_USER_ID')

IMAGE_NAME_MAP = {
    # NodeJS Images
    'NodeJS': 'nodejs',
    'NodeJSDebug': 'nodejs-debug',
    'StandaloneNodeJS': 'standalone-nodejs',
    'StandaloneNodeJSDebug': 'standalone-nodejs-debug',
}

TEST_NAME_MAP = {
    'NodeJS': 'NodeJSTests',
    'NodeJSDebug': 'NodeJSTests',
    'StandaloneNodeJS': 'NodeJSTests',
    'StandaloneNodeJSDebug': 'NodeJSTests',
}

def launch_container(container, **kwargs):
    """
    Launch a specific container
    :param container:
    :return: the container ID
    """
    # Build the container if it doesn't exist
    logger.info("Building %s container..." % container)
    client.images.build(path='../%s' % container,
                        tag="%s/%s:%s" % (NAMESPACE, IMAGE_NAME_MAP[container], VERSION),
                        rm=True)
    logger.info("Done building %s" % container)

    # Run the container
    logger.info("Running %s container..." % container)
    container_id = client.containers.run("%s/%s:%s" % (NAMESPACE, IMAGE_NAME_MAP[container], VERSION),
                                         detach=True,
                                         **kwargs).short_id
    logger.info("%s up and running" % container)
    return container_id


if __name__ == '__main__':
    # The container to test against
    image = sys.argv[1]

    use_random_user_id = USE_RANDOM_USER_ID == 'true'
    random_user_id = random.randint(100000,2147483647)

    if use_random_user_id:
        logger.info("Running tests with a random user ID -> %s" % random_user_id)

    standalone = 'standalone' in image.lower()

    # Flag for failure (for posterity)
    failed = False

    logger.info('========== Starting %s Container ==========' % image)

    if standalone:
        """
        Standalone Configuration
        """
        smoke_test_class = 'StandaloneTest'
        if use_random_user_id:
            test_container_id = launch_container(image, ports={'8080': 8080, '80': 80}, user=random_user_id)
        else:
            test_container_id = launch_container(image, ports={'8080': 8080})

    logger.info('========== / Containers ready to go ==========')

    try:
        # Smoke tests
        logger.info('*********** Running smoke tests %s Tests **********' % image)
        image_class = "%sTest" % image
        test_class = getattr(__import__('SmokeTests', fromlist=[smoke_test_class]), smoke_test_class)
        suite = unittest.TestLoader().loadTestsFromTestCase(test_class)
        test_runner = unittest.TextTestRunner(verbosity=3)
        failed = not test_runner.run(suite).wasSuccessful()
    except Exception as e:
        logger.fatal(e.message)
        failed = True

    try:
        # Run Selenium tests
        logger.info('*********** Running NodeJS tests %s Tests **********' % image)
        test_class = getattr(__import__('NodeJSTests', fromlist=[TEST_NAME_MAP[image]]), TEST_NAME_MAP[image])
        suite = unittest.TestLoader().loadTestsFromTestCase(test_class)
        test_runner = unittest.TextTestRunner(verbosity=3)
        failed = not test_runner.run(suite).wasSuccessful()
    except Exception as e:
        logger.fatal(e.message)
        failed = True

    logger.info("Cleaning up...")

    test_container = client.containers.get(test_container_id)
    test_container.kill()
    test_container.remove()

    if standalone:
        logger.info("Standalone Cleaned up")
    else:
        #Kill the launched hub
        hub = client.containers.get(hub_id)
        hub.kill()
        hub.remove()
        logger.info("Hub / Node Cleaned up")

    if failed:
        exit(1)
