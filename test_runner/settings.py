import configparser
import os


class Settings:
    current_dir = os.path.dirname(__file__)
    config_path = os.path.join(current_dir, '..', 'settings.ini')

    config = configparser.ConfigParser()
    config.read(config_path)

    @classmethod
    def get(cls, key):
        env_key = f"RGSQL_{key.upper()}"
        if os.getenv(env_key):
            return os.getenv(env_key)
        else:
            return cls.config['rgsql'].get(key)
